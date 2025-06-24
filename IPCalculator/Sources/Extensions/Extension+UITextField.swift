import UIKit

extension UITextField {
    func applyIPFormatting(range: NSRange, replacementString string: String, validator: IPAddressValidatable) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet), !string.isEmpty { return false }

        guard let currentText = self.text as NSString? else { return false }
        let newString = currentText.replacingCharacters(in: range, with: string)

        if newString.count > 15 { return false }

        return validator.isValidIntermediateInput(newString)
    }
}
