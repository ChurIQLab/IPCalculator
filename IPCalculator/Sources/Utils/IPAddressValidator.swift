import Foundation

protocol IPAddressValidatable {
    func isValidIntermediateInput(_ input: String) -> Bool
    func isValidFinalIP(_ ip: String) -> Bool
}

struct IPAddressValidator: IPAddressValidatable {
    func isValidIntermediateInput(_ input: String) -> Bool {
        return validate(input, allowEmtyOctets: true, allowTrailingDot: true, requireFourOctets: false)
    }

    func isValidFinalIP(_ ip: String) -> Bool {
        return validate(ip, allowEmtyOctets: false, allowTrailingDot: false, requireFourOctets: true)
    }
}

private extension IPAddressValidator {
    func validate(_ ip: String,
                  allowEmtyOctets: Bool,
                  allowTrailingDot: Bool,
                  requireFourOctets: Bool) -> Bool {
        if ip.hasPrefix(".") || ip.contains("..") || !allowTrailingDot && ip.hasSuffix(".") { return false }

        let components = ip.split(separator: ".", omittingEmptySubsequences: !allowEmtyOctets)
        if requireFourOctets && components.count != 4 { return false }
        if !requireFourOctets && components.count > 4 { return false }

        for octet in components {
            if !allowEmtyOctets && octet.isEmpty { return false }
            if octet.count > 1 && octet.first == "0" { return false }
            if !octet.isEmpty && UInt8(octet) == nil { return false }
        }

        return true
    }
}
