import UIKit

final class SubnetSplitTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "SubnetSplitTableViewCell"

    // MARK: - Outlets

    private let networkLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.applyScaledFont(size: UIConstants.FontSize.body,
                              weight: .semibold,
                              textStyle: .body)
        return label
    }()

    private let hostsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.applyScaledFont(size: UIConstants.FontSize.small,
                              weight: .regular,
                              textStyle: .subheadline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let rangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.applyScaledFont(size: UIConstants.FontSize.small,
                              weight: .regular,
                              textStyle: .subheadline)
        return label
    }()

    private let broadcastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.applyScaledFont(size: UIConstants.FontSize.small,
                              weight: .regular,
                              textStyle: .subheadline)
        return label
    }()

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [networkLabel, hostsLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = UIConstants.Spacing.stackViewSpacing
        return stack
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topStackView, rangeLabel, broadcastLabel])
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.subnetCellLineSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initial

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension SubnetSplitTableViewCell {
    func setupHierarchy() {
        contentView.addSubview(stackView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: UIConstants.Spacing.subnetCellVertical),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: UIConstants.Spacing.cellHorizonal),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -UIConstants.Spacing.cellHorizonal),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -UIConstants.Spacing.subnetCellVertical)
        ])
    }
}

// MARK: - Configure

extension SubnetSplitTableViewCell {
    func configuration(with row: SubnetSplitRowViewModel) {
        networkLabel.text = row.network
        hostsLabel.text = "Hosts: \(row.hosts)"
        rangeLabel.text = row.hostRange
        broadcastLabel.text = "Broadcast: \(row.broadcast)"
    }
}
