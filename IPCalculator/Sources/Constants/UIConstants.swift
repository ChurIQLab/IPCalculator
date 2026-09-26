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
        static let subnetCellVertical: CGFloat = UIScale.scaled(10)
        static let subnetCellLineSpacing: CGFloat = UIScale.scaled(4)
    }

    enum Size {
        static let imageSize: CGFloat = UIScale.scaled(40)
        static let textFieldHeight: CGFloat = UIScale.scaled(40)
        static let buttonHeight: CGFloat = UIScale.scaled(40)
        static let borderWidth: CGFloat = UIScale.scaled(1)
        static let toolbarHeight: CGFloat = UIScale.scaled(44)
        static let minTableRowHeight: CGFloat = UIScale.scaled(36)
        static let subnetCellEstimatedHeight: CGFloat = UIScale.scaled(80)
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
        static let splitNetwork: String = NSLocalizedString("split_network_action", comment: "Result table row that opens the subnet split screen")
        static let splitUnavailable: String = NSLocalizedString("split_unavailable_note", comment: "Result table row for a /32, which cannot be split")
        static let splitTitle: String = NSLocalizedString("split_title", comment: "Subnet split screen title")
        static let splitPrefixLabel: String = NSLocalizedString("split_prefix_label", comment: "Label of the new subnet mask menu on the split screen")
        static let splitSummary: String = NSLocalizedString("split_summary", comment: "Subnet count and hosts in each subnet, e.g. Subnets: 4 · hosts each: 62")
        static let copyWholeSubnet: String = NSLocalizedString("copy_whole_subnet_action", comment: "Context menu action that copies every value of a subnet")
    }

    enum Image {
        static let ipIcon  = "IPCalculatorIcon"
    }
}
