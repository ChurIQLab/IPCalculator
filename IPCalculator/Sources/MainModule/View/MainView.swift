import UIKit

protocol MainViewDelegate: AnyObject {
    func didTapCalculate(with ip: String?)
    func didSelectMask(at index: Int)
}

final class MainView: UIView {

    // MARK: - Properties

    weak var delegate: MainViewDelegate?

    private let mainTableView = MainTableView()
    private let maskPickerView = MaskPickerView()

    // MARK: - Outlets

    private let labelIP: UILabel = {
        let label = UILabel()
        label.text = "IP Address"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textFieldIP: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.layer.cornerRadius = 8
        field.font = .systemFont(ofSize: 20)
        field.keyboardType = .numbersAndPunctuation
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let labelMask: UILabel = {
        let label = UILabel()
        label.text = "Маска"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldMask: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.layer.cornerRadius = 8
        field.font = .systemFont(ofSize: 20)
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
        button.setTitle("Подсчитать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8

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

private extension MainView {
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
            labelIP.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            labelIP.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldIP.topAnchor.constraint(equalTo: labelIP.bottomAnchor, constant: 10),
            textFieldIP.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldIP.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textFieldIP.heightAnchor.constraint(equalToConstant: 50),
            labelMask.topAnchor.constraint(equalTo: textFieldIP.bottomAnchor, constant: 20),
            labelMask.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldMask.topAnchor.constraint(equalTo: labelMask.bottomAnchor, constant: 10),
            textFieldMask.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldMask.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textFieldMask.heightAnchor.constraint(equalToConstant: 50),
            buttonCalculate.topAnchor.constraint(equalTo: textFieldMask.bottomAnchor, constant: 20),
            buttonCalculate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonCalculate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonCalculate.heightAnchor.constraint(equalToConstant: 50),
            tableView.topAnchor.constraint(equalTo: buttonCalculate.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Actions objc

private extension MainView {
    @objc func doneTapped() {
        textFieldMask.resignFirstResponder()
    }
}

// MARK: - Public func

extension MainView {
    func configuration(with model: MainViewModel) {
        mainTableView.configuration(with: model.resultRows)
    }

    func updateTextFieldMask(text: String) {
        textFieldMask.text = text
    }

    func setOptions(_ options: [String]) {
        maskPickerView.configuration(with: options)
    }

    func setSelectedRow(_ row: Int) {
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }
}

// MARK: - Delegate

extension MainView: MaskPickerViewDelegate {
    func didSelectRow(_ row: Int) {
        delegate?.didSelectMask(at: row)
    }
}
