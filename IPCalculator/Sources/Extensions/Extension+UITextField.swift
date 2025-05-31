import UIKit

extension UITextField {
    func applyIPFormatting(range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet), !string.isEmpty { return false }

        guard let currentText = self.text as NSString? else { return false }
        let newString = currentText.replacingCharacters(in: range, with: string)
        let digitsOnly = newString.replacingOccurrences(of: ".", with: "")
        if digitsOnly.count > 12 { return false }

        var formattedString = ""
        for (index, char) in digitsOnly.enumerated() {
            if index > 0 && index % 3 == 0 {
                formattedString.append(".")
            }
            formattedString.append(char)
        }

        let octets = formattedString.split(separator: ".")
        for octet in octets {
            guard UInt8(String(octet)) != nil else { return false }
        }

        text = formattedString
        return false
    }
}
