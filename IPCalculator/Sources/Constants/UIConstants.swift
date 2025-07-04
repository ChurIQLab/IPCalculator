import UIKit

enum UIConstants {
    enum FontSize {
        static let title: CGFloat = 20
        static let body: CGFloat = 16
        static let small: CGFloat = 14
    }

    enum CornerRadius {
        static let normal: CGFloat = 12
        static let button: CGFloat = 8
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = UIScale.scaled(20)
        static let cellHorizonal: CGFloat = UIScale.scaled(16)

        static let labelToTextField: CGFloat = UIScale.scaled(10)
        static let screenVertial: CGFloat = UIScale.scaled(20)

        static let stackViewSpacing: CGFloat = UIScale.scaled(8)
    }

    enum Size {
        static let imageSize: CGFloat = UIScale.scaled(40)
        static let textFieldHeight: CGFloat = UIScale.scaled(40)
        static let buttonHeight: CGFloat = UIScale.scaled(40)
        static let borderWidth: CGFloat = UIScale.scaled(1)
        static let toolbarHeight: CGFloat = UIScale.scaled(44)
    }

    enum Text {
        static let title: String = "NetBits"
        static let ipLabel: String = "IP address"
        static let ipPlaceholder: String = "Enter your IP address"
        static let maskLabel: String = "Netmask"
        static let maskPlaceholder: String = "Enter your netmask"
        static let calculateButton: String = "Calculate"
        static let nameLabel: String = "Name"
        static let valueLabel: String = "Value"
    }

    enum Image {
        static let ipIcon  = "IPCalculatorIcon"
    }
}
