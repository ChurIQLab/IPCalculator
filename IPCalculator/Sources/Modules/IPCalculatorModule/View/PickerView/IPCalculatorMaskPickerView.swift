import UIKit

protocol MaskPickerViewDelegate: AnyObject {
    func didSelectRow(_ row: Int)
}

final class IPCalculatorMaskPickerView: UIView {

    // MARK: - Properties

    weak var delegate: MaskPickerViewDelegate?

    private let numberOfComponents: Int = 1
    private var options: [String] = []

    // MARK: - Outlets

    private(set) lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public methods

extension IPCalculatorMaskPickerView {
    func configuration(with options: [String]) {
        self.options = options
        pickerView.reloadAllComponents()
    }
}

// MARK: - Setup

private extension IPCalculatorMaskPickerView {
    func setupHierarchy() {
        addSubview(pickerView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - DataSource

extension IPCalculatorMaskPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
}

// MARK: - Delegate

extension IPCalculatorMaskPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard !options.isEmpty else { return nil }
        return options[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectRow(row)
    }
}
