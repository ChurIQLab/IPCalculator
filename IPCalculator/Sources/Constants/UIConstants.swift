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
        static let ipLabel: String = NSLocalizedString("ip_address_label", comment: "IP address field label")
        static let ipPlaceholder: String = NSLocalizedString("ip_address_placeholder", comment: "IP address field placeholder")
        static let maskLabel: String = NSLocalizedString("netmask_label", comment: "Netmask field label")
        static let maskPlaceholder: String = NSLocalizedString("netmask_placeholder", comment: "Netmask field placeholder")
        static let calculateButton: String = NSLocalizedString("calculate_button", comment: "Calculate button title")
        static let nameLabel: String = NSLocalizedString("table_name_header", comment: "Result table header, parameter name column")
        static let valueLabel: String = NSLocalizedString("table_value_header", comment: "Result table header, value column")
    }

    enum Image {
        static let ipIcon  = "IPCalculatorIcon"
    }
}
