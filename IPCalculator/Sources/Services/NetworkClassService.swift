import Foundation

protocol NetworkClassDetectable {
    func networkClass(for ip: UInt32) -> NetworkClass
    func networkType(for ip: UInt32) -> NetworkType
}

struct NetworkClassService: NetworkClassDetectable {

    /// Special-purpose ranges, checked in order. They do not overlap, so the
    /// order is only for readability; anything unmatched is globally routable.
    private static let specialRanges: [(network: UInt32, prefix: Int, type: NetworkType)] = [
        (0x7F00_0000, 8,  .loopback),   // 127.0.0.0/8     RFC 1122
        (0x0A00_0000, 8,  .private),    // 10.0.0.0/8      RFC 1918
        (0xAC10_0000, 12, .private),    // 172.16.0.0/12   RFC 1918
        (0xC0A8_0000, 16, .private),    // 192.168.0.0/16  RFC 1918
        (0xA9FE_0000, 16, .linkLocal),  // 169.254.0.0/16  RFC 3927
        (0x6440_0000, 10, .cgnat),      // 100.64.0.0/10   RFC 6598
        (0xE000_0000, 4,  .multicast),  // 224.0.0.0/4     RFC 5771
        (0xF000_0000, 4,  .reserved)    // 240.0.0.0/4     RFC 1112
    ]

    func networkClass(for ip: UInt32) -> NetworkClass {
        switch firstOctet(of: ip) {
        case 0...127: return .a
        case 128...191: return .b
        case 192...223: return .c
        case 224...239: return .d
        default: return .e
        }
    }

    func networkType(for ip: UInt32) -> NetworkType {
        for range in Self.specialRanges where matches(ip, network: range.network, prefix: range.prefix) {
            return range.type
        }
        return .public
    }
}

private extension NetworkClassService {
    func firstOctet(of ip: UInt32) -> UInt8 {
        return UInt8((ip >> 24) & 0xFF)
    }

    func matches(_ ip: UInt32, network: UInt32, prefix: Int) -> Bool {
        let mask = ~UInt32(0) << (32 - prefix)
        return ip & mask == network
    }
}
