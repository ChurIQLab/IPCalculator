import Foundation

/// Address scope — which special-purpose block the address falls into, or
/// `public` when IANA marks the address as globally reachable.
enum NetworkType: String {
    case `private` = "Private"
    case `public` = "Public"
    case thisNetwork = "This network"
    case loopback = "Loopback"
    case linkLocal = "Link-local"
    case cgnat = "CGNAT"
    case multicast = "Multicast"
    case reserved = "Reserved"
    case documentation = "Documentation"
    case benchmarking = "Benchmarking"
    case ietfProtocol = "IETF protocol"
    case sixToFourRelay = "6to4 relay"
    case limitedBroadcast = "Limited broadcast"
}
