import UIKit

final class SubnetNeedTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "SubnetNeedTableViewCell"

    /// Called with the field text after every accepted edit.
    var onChange: ((String) -> Void)?

    /// 4 294 967 294 hosts fill a /0, so ten digits are enough.
    private static let maxDigits = 10

    // MARK: - Outlets

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.applyScaledFont(size: UIConstants.FontSize.body,
                              weight: .medium,
                              textStyle: .body)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = UIConstants.Text.splitNeedPlaceholder
        field.borderStyle = .roundedRect
        field.textColor = .label
        field.applyScaledFont(size: UIConstants.FontSize.body,
                              weight: .regular,
                              textStyle: .body)
        field.keyboardType = .numberPad
        field.inputAccessoryView = toolbar
        field.delegate = self
        field.addAction(
            UIAction { [weak self] _ in
                self?.onChange?(self?.textField.text ?? "")
            },
            for: .editingChanged
        )
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: Int(UIScale.screenWidth),
                                              height: Int(UIConstants.Size.toolbarHeight)))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
            self?.textField.resignFirstResponder()
        })
        toolbar.setItems([space, done], animated: false)
        return toolbar
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

    override func prepareForReuse() {
        super.prepareForReuse()
        onChange = nil
    }
}

// MARK: - Setups

private extension SubnetNeedTableViewCell {
    func setupHierarchy() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(textField)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                 constant: UIConstants.Spacing.cellHorizonal),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            textField.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor,
                                               constant: UIConstants.Spacing.stackViewSpacing),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -UIConstants.Spacing.cellHorizonal),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: UIConstants.Spacing.subnetCellLineSpacing),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -UIConstants.Spacing.subnetCellLineSpacing),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.Size.minTableRowHeight)
        ])
    }
}

// MARK: - Configure

extension SubnetNeedTableViewCell {
    func configuration(number: Int, text: String) {
        numberLabel.text = String(format: UIConstants.Text.splitNeedNumber, number)
        if !textField.isFirstResponder {
            textField.text = text
        }
    }

    func startEditing() {
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension SubnetNeedTableViewCell: UITextFieldDelegate {
    /// Digits only, at most `maxDigits`, and no leading zero, so the field never holds 0.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard string.allSatisfy(\.isASCIIDigit) else { return false }
        let current = (textField.text ?? "") as NSString
        let newText = current.replacingCharacters(in: range, with: string)
        return newText.count <= Self.maxDigits && !newText.hasPrefix("0")
    }
}

private extension Character {
    var isASCIIDigit: Bool {
        return ("0"..."9").contains(self)
    }
}
