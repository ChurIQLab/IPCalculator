import Foundation

/// Address scope — which special-purpose range the address falls into,
/// or `public` when it is globally routable.
enum NetworkType: String {
    case `private` = "Private"
    case `public` = "Public"
    case loopback = "Loopback"
    case linkLocal = "Link-local"
    case cgnat = "CGNAT"
    case multicast = "Multicast"
    case reserved = "Reserved"
}
