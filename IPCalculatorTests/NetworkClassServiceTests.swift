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

    /// Every class boundary, both edges of every special-purpose range, the first
    /// address outside each range, and the addresses around every nested block.
    @Test(arguments: [
        Case("0.0.0.0", .a, .thisNetwork),
        Case("0.255.255.255", .a, .thisNetwork),
        Case("1.0.0.0", .a, .public),
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
        Case("192.0.0.0", .c, .ietfProtocol),
        Case("192.0.0.8", .c, .ietfProtocol),
        Case("192.0.0.9", .c, .public),
        Case("192.0.0.10", .c, .public),
        Case("192.0.0.11", .c, .ietfProtocol),
        Case("192.0.0.255", .c, .ietfProtocol),
        Case("192.0.1.0", .c, .public),
        Case("192.0.1.255", .c, .public),
        Case("192.0.2.0", .c, .documentation),
        Case("192.0.2.255", .c, .documentation),
        Case("192.0.3.0", .c, .public),
        Case("192.88.98.255", .c, .public),
        Case("192.88.99.0", .c, .sixToFourRelay),
        Case("192.88.99.255", .c, .sixToFourRelay),
        Case("192.88.100.0", .c, .public),
        Case("192.167.255.255", .c, .public),
        Case("192.168.0.0", .c, .private),
        Case("192.168.255.255", .c, .private),
        Case("192.169.0.0", .c, .public),
        Case("198.17.255.255", .c, .public),
        Case("198.18.0.0", .c, .benchmarking),
        Case("198.19.255.255", .c, .benchmarking),
        Case("198.20.0.0", .c, .public),
        Case("198.51.99.255", .c, .public),
        Case("198.51.100.0", .c, .documentation),
        Case("198.51.100.255", .c, .documentation),
        Case("198.51.101.0", .c, .public),
        Case("203.0.112.255", .c, .public),
        Case("203.0.113.0", .c, .documentation),
        Case("203.0.113.255", .c, .documentation),
        Case("203.0.114.0", .c, .public),
        Case("223.255.255.255", .c, .public),
        Case("224.0.0.0", .d, .multicast),
        Case("239.255.255.255", .d, .multicast),
        Case("240.0.0.0", .e, .reserved),
        Case("255.255.255.254", .e, .reserved),
        Case("255.255.255.255", .e, .limitedBroadcast)
    ])
    func detectsClassAndType(_ testCase: Case) throws {
        let ip = try #require(formatter.uint32(from: testCase.address))

        #expect(service.networkClass(for: ip) == testCase.networkClass)
        #expect(service.networkType(for: ip) == testCase.type)
    }
}
