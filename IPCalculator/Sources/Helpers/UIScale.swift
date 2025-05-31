import UIKit

struct UIScale {
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height

    static let baseScreenSize: CGFloat = 375

    static var scaleFactor: CGFloat {
        return min(screenWidth, screenHeight) / baseScreenSize
    }

    static func scaled(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * scaleFactor
    }
}
