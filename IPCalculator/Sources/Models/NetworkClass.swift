import Foundation

/// Classful network range (RFC 791), determined by the first octet of the address.
enum NetworkClass: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"

    /// Only D and E still describe how the range is used; A-C are pre-CIDR
    /// legacy and say nothing about the address beyond its first octet.
    var displayName: String {
        switch self {
        case .a, .b, .c: return rawValue
        case .d: return "\(rawValue) (Multicast)"
        case .e: return "\(rawValue) (Reserved)"
        }
    }
}
