import UIKit

final class IPCalculatorTableViewHeader: UITableViewHeaderFooterView {

    // MARK: - Properties

    static let identifier = "IPCalculatorTableViewHeader"

    // MARK: - Outlets

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        label.text = UIConstants.Text.nameLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        label.text = UIConstants.Text.valueLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initial

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension IPCalculatorTableViewHeader {
    func setupHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(separator)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: UIConstants.Spacing.cellHorizonal),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor,
                                                constant: UIConstants.Spacing.cellHorizonal),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separator.widthAnchor.constraint(equalToConstant: UIConstants.Size.borderWidth),
            separator.topAnchor.constraint(equalTo: contentView.topAnchor),
            separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
