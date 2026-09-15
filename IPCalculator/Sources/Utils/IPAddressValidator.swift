import Foundation

protocol IPAddressValidatable {
    func isValidIntermediateInput(_ input: String) -> Bool
    func isValidFinalIP(_ ip: String) -> Bool
    func cidrComponents(from input: String) -> (address: String, prefix: Int?)?
}

struct IPAddressValidator: IPAddressValidatable {
    func isValidIntermediateInput(_ input: String) -> Bool {
        let parts = input.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count <= 2 else { return false }

        let addressPart = String(parts[0])
        guard validate(addressPart, allowEmptyOctets: true, allowTrailingDot: true, requireFourOctets: false) else {
            return false
        }
        guard parts.count == 2 else { return true }

        let prefixPart = String(parts[1])
        if prefixPart.isEmpty { return true }
        guard prefixPart.count <= 2, let prefix = Int(prefixPart) else { return false }
        return prefix <= 32
    }

    func isValidFinalIP(_ ip: String) -> Bool {
        return cidrComponents(from: ip) != nil
    }

    func cidrComponents(from input: String) -> (address: String, prefix: Int?)? {
        let parts = input.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count <= 2 else { return nil }

        let addressPart = String(parts[0])
        guard validate(addressPart, allowEmptyOctets: false, allowTrailingDot: false, requireFourOctets: true) else {
            return nil
        }
        guard parts.count == 2 else { return (addressPart, nil) }

        guard let prefix = Int(parts[1]), (0...32).contains(prefix) else { return nil }
        return (addressPart, prefix)
    }
}

private extension IPAddressValidator {
    func validate(_ ip: String,
                  allowEmptyOctets: Bool,
                  allowTrailingDot: Bool,
                  requireFourOctets: Bool) -> Bool {
        if ip.hasPrefix(".") || ip.contains("..") || !allowTrailingDot && ip.hasSuffix(".") { return false }

        let components = ip.split(separator: ".", omittingEmptySubsequences: !allowEmptyOctets)
        if requireFourOctets && components.count != 4 { return false }
        if !requireFourOctets && components.count > 4 { return false }

        for octet in components {
            if !allowEmptyOctets && octet.isEmpty { return false }
            if octet.count > 1 && octet.first == "0" { return false }
            if !octet.isEmpty && UInt8(octet) == nil { return false }
        }

        return true
    }
}
