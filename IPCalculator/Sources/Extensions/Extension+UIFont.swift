import UIKit

protocol FontApplecable {
    func applyScaledFont(size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle)
}

extension UIFont {
    static func scalableFont(size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
    }
}

extension UILabel: FontApplecable {
    func applyScaledFont(size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) {
        font = .scalableFont(size: size, weight: weight, textStyle: textStyle)
        adjustsFontForContentSizeCategory = true
    }
}

extension UIButton: FontApplecable {
    func applyScaledFont(size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) {
        titleLabel?.font = .scalableFont(size: size, weight: weight, textStyle: textStyle)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}

extension UITextField: FontApplecable {
    func applyScaledFont(size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) {
        font = .scalableFont(size: size, weight: weight, textStyle: textStyle)
        adjustsFontForContentSizeCategory = true
    }
}
