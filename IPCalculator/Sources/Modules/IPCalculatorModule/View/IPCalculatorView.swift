import UIKit

protocol IPCalculatorViewDelegate: AnyObject {
    func didTapCalculate(with ip: String?)
    func didSelectMask(at index: Int)
}

final class IPCalculatorView: UIView {

    // MARK: - Properties

    weak var delegate: IPCalculatorViewDelegate?

    private let mainTableView = IPCalculatorTableView()
    private let maskPickerView = IPCalculatorMaskPickerView()

    // MARK: - Outlets

    private let labelIP: UILabel = {
        let label = UILabel()
        label.text = UIConstants.Text.ipLabel
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textFieldIP: UITextField = {
        let field = UITextField()
        field.placeholder = UIConstants.Text.ipPlaceholder
        field.borderStyle = .roundedRect
        field.layer.cornerRadius = UIConstants.CornerRadius.normal
        field.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .regular,
                              textStyle: .body)
        field.keyboardType = .numbersAndPunctuation
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let labelMask: UILabel = {
        let label = UILabel()
        label.text = UIConstants.Text.maskLabel
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldMask: UITextField = {
        let field = UITextField()
        field.placeholder = UIConstants.Text.maskPlaceholder
        field.borderStyle = .roundedRect
        field.layer.cornerRadius = UIConstants.CornerRadius.normal
        field.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .regular,
                              textStyle: .body)
        field.inputView = pickerView
        field.inputAccessoryView = toolbar
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var pickerView: UIPickerView = {
        let picker = maskPickerView.pickerView
        return picker
    }()

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([done], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }()

    private lazy var buttonCalculate: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(UIConstants.Text.calculateButton, for: .normal)
        button.titleLabel?.applyScaledFont(size: UIConstants.FontSize.title,
                                           weight: .bold,
                                           textStyle: .body)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = UIConstants.CornerRadius.button

        button.addAction(
            UIAction { [weak self] _ in
                self?.endEditing(true)
                self?.delegate?.didTapCalculate(with: self?.textFieldIP.text)
            },
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let table = mainTableView.tableView
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Initial

    init() {
        super.init(frame: .zero)
        setupView()
        setupHierarchy()
        setupLayout()
        maskPickerView.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension IPCalculatorView {
    func setupView() {
        backgroundColor = .white
    }

    func setupHierarchy() {
        addSubview(labelIP)
        addSubview(textFieldIP)
        addSubview(labelMask)
        addSubview(textFieldMask)
        addSubview(buttonCalculate)
        addSubview(tableView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            labelIP.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                         constant: UIConstants.Spacing.screenVertial),
            labelIP.leadingAnchor.constraint(equalTo: leadingAnchor,
                                             constant: UIConstants.Spacing.screenHorizontal),
            textFieldIP.topAnchor.constraint(equalTo: labelIP.bottomAnchor,
                                             constant: UIConstants.Spacing.labelToTextField),
            textFieldIP.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: UIConstants.Spacing.screenHorizontal),
            textFieldIP.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                  constant: -UIConstants.Spacing.screenHorizontal),
            textFieldIP.heightAnchor.constraint(equalToConstant: UIConstants.Size.textFieldHeight),
            labelMask.topAnchor.constraint(equalTo: textFieldIP.bottomAnchor,
                                           constant:  UIConstants.Spacing.screenVertial),
            labelMask.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: UIConstants.Spacing.screenHorizontal),
            textFieldMask.topAnchor.constraint(equalTo: labelMask.bottomAnchor,
                                               constant: UIConstants.Spacing.labelToTextField),
            textFieldMask.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                   constant: UIConstants.Spacing.screenHorizontal),
            textFieldMask.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -UIConstants.Spacing.screenHorizontal),
            textFieldMask.heightAnchor.constraint(equalToConstant: UIConstants.Size.textFieldHeight),
            buttonCalculate.topAnchor.constraint(equalTo: textFieldMask.bottomAnchor,
                                                 constant:  UIConstants.Spacing.screenVertial),
            buttonCalculate.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                     constant: UIConstants.Spacing.screenHorizontal),
            buttonCalculate.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                      constant: -UIConstants.Spacing.screenHorizontal),
            buttonCalculate.heightAnchor.constraint(equalToConstant: UIConstants.Size.buttonHeight),
            tableView.topAnchor.constraint(equalTo: buttonCalculate.bottomAnchor,
                                           constant:  UIConstants.Spacing.screenVertial),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: UIConstants.Spacing.screenHorizontal),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -UIConstants.Spacing.screenHorizontal),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                              constant: -UIConstants.Spacing.screenVertial)
        ])
    }
}

// MARK: - Actions objc

private extension IPCalculatorView {
    @objc func doneTapped() {
        textFieldMask.resignFirstResponder()
    }
}

// MARK: - Public func

extension IPCalculatorView {
    func configuration(with model: IPCalculatorViewModel) {
        mainTableView.configuration(with: model.rows)
    }

    func updateTextFieldMask(text: String) {
        textFieldMask.text = text
    }

    func setOptions(_ options: [String]) {
        maskPickerView.configuration(with: options)
    }

    func showTableView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.isHidden = false
        }
    }
}

// MARK: - Delegate

extension IPCalculatorView: MaskPickerViewDelegate {
    func didSelectRow(_ row: Int) {
        delegate?.didSelectMask(at: row)
    }
}
