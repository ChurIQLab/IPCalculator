import Foundation

protocol IPAddressFormattable {
    func string(from value: UInt32) -> String
    func bytes(from value: UInt32) -> [UInt8]
    func uint32(from string: String) -> UInt32?
}

struct IPAddressFormatter: IPAddressFormattable {
    func string(from value: UInt32) -> String {
        let b = bytes(from: value)
        return "\(b[0]).\(b[1]).\(b[2]).\(b[3])"
    }
    
    func bytes(from value: UInt32) -> [UInt8] {
        return [
            UInt8((value >> 24) & 0xFF),
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8(value & 0xFF)
        ]
    }

    func uint32(from string: String) -> UInt32? {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else { return nil }

        var result: UInt32 = 0

        for part in parts {
            guard let byte = UInt8(part) else { return nil }
            result = (result << 8) + UInt32(byte)
        }
        return result
    }
}
