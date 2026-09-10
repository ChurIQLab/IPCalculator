import Testing
@testable import IPCalculator

struct SubnetMaskModelTests {

    @Test(arguments: [
        (0, UInt32(0x0000_0000)),
        (1, UInt32(0x8000_0000)),
        (8, UInt32(0xFF00_0000)),
        (12, UInt32(0xFFF0_0000)),
        (24, UInt32(0xFFFF_FF00)),
        (31, UInt32(0xFFFF_FFFE)),
        (32, UInt32(0xFFFF_FFFF))
    ])
    func buildsSubnetForPrefix(prefix: Int, expected: UInt32) {
        #expect(SubnetMaskModel(prefix: prefix).subnet == expected)
    }

    @Test(arguments: 0...32)
    func subnetIsContiguous(prefix: Int) {
        let subnet = SubnetMaskModel(prefix: prefix).subnet
        let wildcard = ~subnet

        #expect(subnet.nonzeroBitCount == prefix)
        #expect(wildcard & (wildcard &+ 1) == 0)
    }

    @Test func defaultListsEveryPrefixInOrder() {
        #expect(SubnetMaskModel.default.map(\.prefix) == Array(0...32))
    }
}
