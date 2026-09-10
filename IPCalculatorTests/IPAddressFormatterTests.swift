import Testing
@testable import IPCalculator

struct IPAddressFormatterTests {

    private let formatter = IPAddressFormatter()

    @Test(arguments: [
        (UInt32(0x0000_0000), "0.0.0.0"),
        (UInt32(0x0A00_0001), "10.0.0.1"),
        (UInt32(0xC0A8_010A), "192.168.1.10"),
        (UInt32(0xFFFF_FFFF), "255.255.255.255")
    ])
    func formatsDottedDecimal(value: UInt32, expected: String) {
        #expect(formatter.string(from: value) == expected)
    }

    @Test(arguments: [
        (UInt32(0x0000_0000), "00000000.00000000.00000000.00000000"),
        (UInt32(0xC0A8_010A), "11000000.10101000.00000001.00001010"),
        (UInt32(0xFFFF_FF00), "11111111.11111111.11111111.00000000")
    ])
    func formatsBinaryWithZeroPaddedOctets(value: UInt32, expected: String) {
        #expect(formatter.binaryString(from: value) == expected)
    }

    @Test func splitsIntoBytesMostSignificantFirst() {
        #expect(formatter.bytes(from: 0x0A14_1E28) == [10, 20, 30, 40])
    }

    @Test(arguments: [
        ("0.0.0.0", UInt32(0x0000_0000)),
        ("10.0.0.1", UInt32(0x0A00_0001)),
        ("192.168.1.10", UInt32(0xC0A8_010A)),
        ("255.255.255.255", UInt32(0xFFFF_FFFF))
    ])
    func parsesDottedDecimal(string: String, expected: UInt32) {
        #expect(formatter.uint32(from: string) == expected)
    }

    @Test(arguments: ["", "1.2.3", "1.2.3.4.5", "256.0.0.1", "1.2.3.-4", "a.b.c.d", "1.2.3.4/24"])
    func rejectsMalformedAddress(_ string: String) {
        #expect(formatter.uint32(from: string) == nil)
    }
}
