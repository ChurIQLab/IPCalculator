import Testing
@testable import IPCalculator

struct IPCalculationServiceTests {

    struct Case: Sendable, CustomTestStringConvertible {
        let address: String
        let prefix: Int
        let netmask: String
        let wildcard: String
        let network: String
        let broadcast: String
        let hostMin: String
        let hostMax: String
        let hostCount: Int

        var testDescription: String { "\(address)/\(prefix)" }
    }

    private let formatter = IPAddressFormatter()
    private let service = IPCalculationService(classDetector: NetworkClassDetectorStub())

    @Test(arguments: [
        Case(address: "192.168.1.10", prefix: 24,
             netmask: "255.255.255.0", wildcard: "0.0.0.255",
             network: "192.168.1.0", broadcast: "192.168.1.255",
             hostMin: "192.168.1.1", hostMax: "192.168.1.254", hostCount: 254),
        Case(address: "10.20.30.40", prefix: 8,
             netmask: "255.0.0.0", wildcard: "0.255.255.255",
             network: "10.0.0.0", broadcast: "10.255.255.255",
             hostMin: "10.0.0.1", hostMax: "10.255.255.254", hostCount: 16_777_214),
        Case(address: "172.16.5.4", prefix: 12,
             netmask: "255.240.0.0", wildcard: "0.15.255.255",
             network: "172.16.0.0", broadcast: "172.31.255.255",
             hostMin: "172.16.0.1", hostMax: "172.31.255.254", hostCount: 1_048_574),
        Case(address: "192.168.1.130", prefix: 26,
             netmask: "255.255.255.192", wildcard: "0.0.0.63",
             network: "192.168.1.128", broadcast: "192.168.1.191",
             hostMin: "192.168.1.129", hostMax: "192.168.1.190", hostCount: 62),
        Case(address: "192.168.1.1", prefix: 30,
             netmask: "255.255.255.252", wildcard: "0.0.0.3",
             network: "192.168.1.0", broadcast: "192.168.1.3",
             hostMin: "192.168.1.1", hostMax: "192.168.1.2", hostCount: 2),
        Case(address: "10.0.0.0", prefix: 31,
             netmask: "255.255.255.254", wildcard: "0.0.0.1",
             network: "10.0.0.0", broadcast: "10.0.0.1",
             hostMin: "10.0.0.0", hostMax: "10.0.0.1", hostCount: 2),
        Case(address: "10.0.0.1", prefix: 31,
             netmask: "255.255.255.254", wildcard: "0.0.0.1",
             network: "10.0.0.0", broadcast: "10.0.0.1",
             hostMin: "10.0.0.0", hostMax: "10.0.0.1", hostCount: 2),
        Case(address: "10.0.0.5", prefix: 32,
             netmask: "255.255.255.255", wildcard: "0.0.0.0",
             network: "10.0.0.5", broadcast: "10.0.0.5",
             hostMin: "10.0.0.5", hostMax: "10.0.0.5", hostCount: 1),
        Case(address: "8.8.8.8", prefix: 0,
             netmask: "0.0.0.0", wildcard: "255.255.255.255",
             network: "0.0.0.0", broadcast: "255.255.255.255",
             hostMin: "0.0.0.1", hostMax: "255.255.255.254", hostCount: 4_294_967_294)
    ])
    func calculatesSubnet(_ testCase: Case) throws {
        let model = try calculate(testCase.address, prefix: testCase.prefix)

        #expect(model.prefix == testCase.prefix)
        #expect(formatter.string(from: model.netmask) == testCase.netmask)
        #expect(formatter.string(from: model.wildcard) == testCase.wildcard)
        #expect(formatter.string(from: model.network) == testCase.network)
        #expect(formatter.string(from: model.broadcast) == testCase.broadcast)
        #expect(formatter.string(from: model.usableHostMin) == testCase.hostMin)
        #expect(formatter.string(from: model.usableHostMax) == testCase.hostMax)
        #expect(model.hostCount == testCase.hostCount)
    }

    @Test func takesClassAndTypeFromInjectedDetector() {
        let detector = NetworkClassDetectorStub(stubbedClass: .e, stubbedType: .reserved)
        let service = IPCalculationService(classDetector: detector)

        let model = service.calculate(ip: 0x0A00_0001, subnetMask: SubnetMaskModel(prefix: 8))

        #expect(model.networkClass == .e)
        #expect(model.networkType == .reserved)
    }
}

private extension IPCalculationServiceTests {
    func calculate(_ address: String, prefix: Int) throws -> IPCalculationModel {
        let ip = try #require(formatter.uint32(from: address))
        return service.calculate(ip: ip, subnetMask: SubnetMaskModel(prefix: prefix))
    }
}

private struct NetworkClassDetectorStub: NetworkClassDetectable {
    var stubbedClass: NetworkClass = .a
    var stubbedType: NetworkType = .public

    func networkClass(for ip: UInt32) -> NetworkClass {
        return stubbedClass
    }

    func networkType(for ip: UInt32) -> NetworkType {
        return stubbedType
    }
}
