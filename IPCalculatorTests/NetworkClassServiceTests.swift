import Testing
@testable import IPCalculator

struct NetworkClassServiceTests {

    struct Case: Sendable, CustomTestStringConvertible {
        let address: String
        let networkClass: NetworkClass
        let type: NetworkType

        init(_ address: String, _ networkClass: NetworkClass, _ type: NetworkType) {
            self.address = address
            self.networkClass = networkClass
            self.type = type
        }

        var testDescription: String { address }
    }

    private let service = NetworkClassService()
    private let formatter = IPAddressFormatter()

    /// Every class boundary, both edges of every special-purpose range, and the
    /// first address outside each range.
    @Test(arguments: [
        Case("0.0.0.0", .a, .public),
        Case("9.255.255.255", .a, .public),
        Case("10.0.0.0", .a, .private),
        Case("10.255.255.255", .a, .private),
        Case("11.0.0.0", .a, .public),
        Case("100.63.255.255", .a, .public),
        Case("100.64.0.0", .a, .cgnat),
        Case("100.127.255.255", .a, .cgnat),
        Case("100.128.0.0", .a, .public),
        Case("126.255.255.255", .a, .public),
        Case("127.0.0.0", .a, .loopback),
        Case("127.255.255.255", .a, .loopback),
        Case("128.0.0.0", .b, .public),
        Case("169.253.255.255", .b, .public),
        Case("169.254.0.0", .b, .linkLocal),
        Case("169.254.255.255", .b, .linkLocal),
        Case("169.255.0.0", .b, .public),
        Case("172.15.255.255", .b, .public),
        Case("172.16.0.0", .b, .private),
        Case("172.31.255.255", .b, .private),
        Case("172.32.0.0", .b, .public),
        Case("191.255.255.255", .b, .public),
        Case("192.167.255.255", .c, .public),
        Case("192.168.0.0", .c, .private),
        Case("192.168.255.255", .c, .private),
        Case("192.169.0.0", .c, .public),
        Case("223.255.255.255", .c, .public),
        Case("224.0.0.0", .d, .multicast),
        Case("239.255.255.255", .d, .multicast),
        Case("240.0.0.0", .e, .reserved),
        Case("255.255.255.255", .e, .reserved)
    ])
    func detectsClassAndType(_ testCase: Case) throws {
        let ip = try #require(formatter.uint32(from: testCase.address))

        #expect(service.networkClass(for: ip) == testCase.networkClass)
        #expect(service.networkType(for: ip) == testCase.type)
    }
}
