import UIKit

protocol MainViewProtocol: AnyObject {
    func display(with model: MainViewModel)
    func updateSelectMaskText(_ text: String)
    func setAvailableMasks(_ masks: [String])
}

final class MainViewController: UIViewController {

    // MARK: - Properties

    private let presenter: MainPresenterProtocol
    private lazy var customView = MainView()

    // MARK: - Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        setupTapGesture()

        customView.delegate = self
        presenter.viewDidLoad()
    }

    // MARK: - Initial

    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension MainViewController {
    func setupTitle() {
        title = "IP Калькулятор"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Objc Action

private extension MainViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - MainViewProtocol

extension MainViewController: MainViewProtocol {
    func display(with model: MainViewModel) {
        customView.configuration(with: model)
    }

    func updateSelectMaskText(_ text: String) {
        customView.updateTextFieldMask(text: text)
    }
    
    func setAvailableMasks(_ masks: [String]) {
        customView.setOptions(masks)
    }
}

// MARK: - Delegate

extension MainViewController: MainViewDelegate {
    func didTapCalculate(with ip: String?) {
        guard let ip = ip else { return }
        presenter.didTapCalculate(with: ip)
    }

    func didSelectMask(at index: Int) {
        presenter.didSelectMask(at: index)
    }
}
