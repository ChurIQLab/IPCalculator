import Foundation

protocol NetworkClassDetectable {
    func networkClass(for ip: UInt32) -> NetworkClass
    func networkType(for ip: UInt32) -> NetworkType
}

struct NetworkClassService: NetworkClassDetectable {

    /// Special-purpose blocks. When blocks nest, the longest matching prefix wins,
    /// as in routing, so the order below is only for readability. The `public`
    /// entries are globally reachable addresses inside a special-purpose block;
    /// anything unmatched is globally reachable too.
    private static let specialRanges: [(network: UInt32, prefix: Int, type: NetworkType)] = [
        (0x0000_0000, 8,  .thisNetwork),      // 0.0.0.0/8           RFC 791
        (0x0A00_0000, 8,  .private),          // 10.0.0.0/8          RFC 1918
        (0x6440_0000, 10, .cgnat),            // 100.64.0.0/10       RFC 6598
        (0x7F00_0000, 8,  .loopback),         // 127.0.0.0/8         RFC 1122
        (0xA9FE_0000, 16, .linkLocal),        // 169.254.0.0/16      RFC 3927
        (0xAC10_0000, 12, .private),          // 172.16.0.0/12       RFC 1918
        (0xC000_0000, 24, .ietfProtocol),     // 192.0.0.0/24        RFC 6890
        (0xC000_0009, 32, .public),           // 192.0.0.9/32        RFC 7723
        (0xC000_000A, 32, .public),           // 192.0.0.10/32       RFC 8155
        (0xC000_0200, 24, .documentation),    // 192.0.2.0/24        RFC 5737
        (0xC058_6300, 24, .sixToFourRelay),   // 192.88.99.0/24      RFC 7526
        (0xC0A8_0000, 16, .private),          // 192.168.0.0/16      RFC 1918
        (0xC612_0000, 15, .benchmarking),     // 198.18.0.0/15       RFC 2544
        (0xC633_6400, 24, .documentation),    // 198.51.100.0/24     RFC 5737
        (0xCB00_7100, 24, .documentation),    // 203.0.113.0/24      RFC 5737
        (0xE000_0000, 4,  .multicast),        // 224.0.0.0/4         RFC 5771
        (0xF000_0000, 4,  .reserved),         // 240.0.0.0/4         RFC 1112
        (0xFFFF_FFFF, 32, .limitedBroadcast)  // 255.255.255.255/32  RFC 919
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
        let match = Self.specialRanges
            .filter { matches(ip, network: $0.network, prefix: $0.prefix) }
            .max { $0.prefix < $1.prefix }
        return match?.type ?? .public
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
