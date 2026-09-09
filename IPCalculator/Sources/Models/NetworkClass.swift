import Foundation

/// Classful network range (RFC 791), determined by the first octet of the
/// address. Superseded by CIDR in 1993 — kept because the ranges still show up
/// in networking coursework and in the classic `ipcalc` output.
enum NetworkClass: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
}
