import Foundation

/// Address scope — whether the address is routable on the public internet.
enum NetworkType: String {
    case `private` = "Private"
    case `public` = "Public"
    case loopback = "Loopback"
}
