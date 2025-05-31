import UIKit

final class IPCalculatorTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "IPCalculatorTableViewCell"

    // MARK: - Outlets

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyScaledFont(size: UIConstants.FontSize.body,
                              weight: .medium,
                              textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.applyScaledFont(size: UIConstants.FontSize.body,
                              weight: .medium,
                              textStyle: .body)
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension IPCalculatorTableViewCell {
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

// MARK: - Configure

extension IPCalculatorTableViewCell {
    func configuration(with row: IPCalculatorTableViewModel) {
        titleLabel.text = row.title
        valueLabel.text = row.value
    }
}
