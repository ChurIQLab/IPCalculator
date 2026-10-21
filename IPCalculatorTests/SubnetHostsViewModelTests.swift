import Testing
@testable import IPCalculator

struct SubnetHostsViewModelTests {

    private let formatter = IPAddressFormatter()
    private let calculator = IPCalculationService(classDetector: NetworkClassService())

    @Test func freeSpaceRunsToTheEndOfTheAddressSpace() throws {
        let network = calculator.calculate(ip: 0xFFFF_FF00, subnetMask: SubnetMaskModel(prefix: 24))
        let allocations = try SubnetSplitService(calculator: calculator)
            .split(ip: 0xFFFF_FF00, subnetMask: SubnetMaskModel(prefix: 24), hostCounts: [2])

        let viewModel = SubnetHostsViewModel(
            network: network,
            needs: [2],
            outcome: .placed(allocations.map { (needNumber: $0.requestIndex + 1, allocation: $0) }),
            formatter: formatter
        )

        #expect(viewModel.freeRange == "255.255.255.4 – 255.255.255.255")
        #expect(viewModel.freeAddressCount == 252)
    }

    @Test func shareBlockStartsWithTheRequirementLine() {
        let subnet = calculator.calculate(ip: 0xC0A8_0A40, subnetMask: SubnetMaskModel(prefix: 27))
        let row = SubnetHostsRowViewModel(
            needNumber: 2,
            hostsNeeded: 25,
            subnet: SubnetSplitRowViewModel(model: subnet, formatter: formatter)
        )

        // The requirement line is localized, so only the subnet block after it is compared.
        let lines = row.shareText.components(separatedBy: "\n")
        #expect(lines.count == 6)
        #expect(lines.dropFirst().joined(separator: "\n") == """
        192.168.10.64/27
        Hostmin: 192.168.10.65
        Hostmax: 192.168.10.94
        Broadcast: 192.168.10.95
        Hosts: 30
        """)
    }

    @Test func notEnoughSpaceHasNoRowsAndNothingToShare() {
        let network = calculator.calculate(ip: 0xC0A8_0A00, subnetMask: SubnetMaskModel(prefix: 24))

        let viewModel = SubnetHostsViewModel(
            network: network,
            needs: [300],
            outcome: .notEnoughSpace(needNumber: 1, hostCount: 300),
            formatter: formatter
        )

        #expect(viewModel.isError)
        #expect(viewModel.failedNeedNumber == 1)
        #expect(viewModel.rows.isEmpty)
        #expect(viewModel.shareText == nil)
        #expect(viewModel.needTexts == ["300"])
    }
}
