import UIKit

protocol IPCalculatorViewProtocol: AnyObject {
    func display(with model: IPCalculatorViewModel)
    func updateSelectMaskText(_ text: String)
    func setAvailableMasks(_ masks: [String])
}

final class IPCalculatorViewController: UIViewController {

    // MARK: - Properties

    private let presenter: IPCalculatorProtocol
    private lazy var customView = IPCalculatorView()

    // MARK: - Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle()
        setupTapGesture()

        customView.delegate = self
        presenter.viewDidLoad()
    }

    // MARK: - Initial

    init(presenter: IPCalculatorProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension IPCalculatorViewController {
    func setupNavigationTitle() {
        navigationItem.titleView = NavigationTitleView()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Objc Action

private extension IPCalculatorViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - IPCalculatorViewProtocol

extension IPCalculatorViewController: IPCalculatorViewProtocol {
    func display(with model: IPCalculatorViewModel) {
        customView.configuration(with: model)
        customView.showTableView()
    }

    func updateSelectMaskText(_ text: String) {
        customView.updateTextFieldMask(text: text)
    }
    
    func setAvailableMasks(_ masks: [String]) {
        customView.setOptions(masks)
    }
}

// MARK: - Delegate

extension IPCalculatorViewController: IPCalculatorViewDelegate {
    func didTapCalculate(with ip: String?) {
        guard let ip = ip else { return }
        presenter.didTapCalculate(with: ip)
    }

    func didSelectMask(at index: Int) {
        presenter.didSelectMask(at: index)
    }
}
