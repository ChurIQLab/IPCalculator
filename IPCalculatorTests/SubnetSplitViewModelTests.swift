import Testing
@testable import IPCalculator

struct SubnetSplitViewModelTests {

    private let formatter = IPAddressFormatter()
    private let calculator = IPCalculationService(classDetector: NetworkClassService())

    @Test func rowShowsNetworkRangeBroadcastAndHosts() {
        let subnet = calculator.calculate(ip: 0xC0A8_0140, subnetMask: SubnetMaskModel(prefix: 26))

        let row = SubnetSplitRowViewModel(model: subnet, formatter: formatter)

        #expect(row.network == "192.168.1.64/26")
        #expect(row.hostRange == "192.168.1.65 – 192.168.1.126")
        #expect(row.broadcast == "192.168.1.127")
        #expect(row.hosts == "62")
    }

    @Test func rowCopyItemsKeepEnglishLabels() {
        let subnet = calculator.calculate(ip: 0xC0A8_0140, subnetMask: SubnetMaskModel(prefix: 26))

        let row = SubnetSplitRowViewModel(model: subnet, formatter: formatter)

        #expect(row.items.map(\.title) == ["Network", "Hostmin", "Hostmax", "Broadcast", "Hosts"])
        #expect(row.shareText == """
        192.168.1.64/26
        Hostmin: 192.168.1.65
        Hostmax: 192.168.1.126
        Broadcast: 192.168.1.127
        Hosts: 62
        """)
    }

    @Test func slash32RowHasOneHost() {
        let subnet = calculator.calculate(ip: 0x0A00_0001, subnetMask: SubnetMaskModel(prefix: 32))

        let row = SubnetSplitRowViewModel(model: subnet, formatter: formatter)

        #expect(row.hostRange == "10.0.0.1 – 10.0.0.1")
        #expect(row.hosts == "1")
    }

    @Test func shareTextStartsWithNetworkAndNewPrefixThenBlocks() {
        let network = calculator.calculate(ip: 0xC0A8_010A, subnetMask: SubnetMaskModel(prefix: 24))
        let subnets = [0xC0A8_0100, 0xC0A8_0180].map {
            calculator.calculate(ip: UInt32($0), subnetMask: SubnetMaskModel(prefix: 25))
        }
        let options = [25, 26].map { IPCalculatorMaskViewModel(model: SubnetMaskModel(prefix: $0), formatter: formatter) }

        let viewModel = SubnetSplitViewModel(
            network: network,
            prefixOptions: options,
            selectedPrefixIndex: 0,
            subnets: subnets,
            formatter: formatter
        )

        // The line after the header is the localized summary, so only its neighbours are checked.
        let blocks = viewModel.shareText.components(separatedBy: "\n\n")
        #expect(viewModel.networkText == "192.168.1.0/24")
        #expect(viewModel.prefixOptions == ["25 - 255.255.255.128", "26 - 255.255.255.192"])
        #expect(blocks.count == 3)
        #expect(blocks.first?.hasPrefix("192.168.1.0/24 → /25\n") == true)
        #expect(blocks.dropFirst().map { $0.components(separatedBy: "\n").first } == ["192.168.1.0/25", "192.168.1.128/25"])
    }
}
