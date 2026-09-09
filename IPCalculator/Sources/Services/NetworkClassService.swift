import Foundation

protocol NetworkClassDetectable {
    func networkClass(for ip: UInt32) -> NetworkClass
    func networkType(for ip: UInt32) -> NetworkType
}

struct NetworkClassService: NetworkClassDetectable {
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
        if isLoopback(ip) { return .loopback }
        if isPrivate(ip) { return .private }
        return .public
    }
}

private extension NetworkClassService {
    func firstOctet(of ip: UInt32) -> UInt8 {
        return UInt8((ip >> 24) & 0xFF)
    }

    /// 127.0.0.0/8
    func isLoopback(_ ip: UInt32) -> Bool {
        return matches(ip, network: 0x7F00_0000, prefix: 8)
    }

    /// RFC 1918 ranges.
    func isPrivate(_ ip: UInt32) -> Bool {
        return matches(ip, network: 0x0A00_0000, prefix: 8)      // 10.0.0.0/8
            || matches(ip, network: 0xAC10_0000, prefix: 12)     // 172.16.0.0/12
            || matches(ip, network: 0xC0A8_0000, prefix: 16)     // 192.168.0.0/16
    }

    func matches(_ ip: UInt32, network: UInt32, prefix: Int) -> Bool {
        let mask = ~UInt32(0) << (32 - prefix)
        return ip & mask == network
    }
}
