import Testing
@testable import IPCalculator

struct IPCalculatorViewModelTests {

    private let model = IPCalculationModel(
        ip: 0xC0A8_010A,
        prefix: 24,
        netmask: 0xFFFF_FF00,
        wildcard: 0x0000_00FF,
        network: 0xC0A8_0100,
        broadcast: 0xC0A8_01FF,
        usableHostMin: 0xC0A8_0101,
        usableHostMax: 0xC0A8_01FE,
        hostCount: 254,
        networkClass: .c,
        networkType: .private
    )

    @Test func tableShowsEveryRowIncludingBinary() {
        let viewModel = IPCalculatorViewModel(model: model, formatter: IPAddressFormatter())

        #expect(viewModel.rows.map(\.title) == [
            "Address", "Address (bin)", "Netmask", "Netmask (bin)", "Wildcard", "Network",
            "Broadcast", "Hostmin", "Hostmax", "Hosts", "Class", "Type"
        ])
    }

    @Test func shareTextStartsWithInputAndSkipsBinaryRows() {
        let viewModel = IPCalculatorViewModel(model: model, formatter: IPAddressFormatter())

        #expect(viewModel.shareText == """
        192.168.1.10/24

        Address: 192.168.1.10
        Netmask: 255.255.255.0
        Wildcard: 0.0.0.255
        Network: 192.168.1.0
        Broadcast: 192.168.1.255
        Hostmin: 192.168.1.1
        Hostmax: 192.168.1.254
        Hosts: 254
        Class: C
        Type: Private
        """)
    }
}
