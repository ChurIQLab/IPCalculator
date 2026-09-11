import UIKit

protocol IPCalculatorViewProtocol: AnyObject {
    func display(with model: IPCalculatorViewModel)
    func updateSelectMask(at index: Int, text: String)
    func setAvailableMasks(_ masks: [String])
    func stripCIDRSuffixFromIPField()
    func presentShareSheet(text: String)
}

final class IPCalculatorViewController: UIViewController {

    // MARK: - Properties

    private let presenter: IPCalculatorProtocol
    private let ipValidator: IPAddressValidatable
    private lazy var customView = IPCalculatorView(ipValidator: ipValidator)
    private lazy var shareButton = UIBarButtonItem(
        systemItem: .action,
        primaryAction: UIAction { [weak self] _ in
            self?.presenter.didTapShare()
        }
    )

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

    init(presenter: IPCalculatorProtocol, ipValidator: IPAddressValidatable) {
        self.presenter = presenter
        self.ipValidator = ipValidator
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

    func showShareButton() {
        guard navigationItem.rightBarButtonItem == nil else { return }
        navigationItem.setRightBarButton(shareButton, animated: true)
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
        showShareButton()
    }

    func updateSelectMask(at index: Int, text: String) {
        customView.updateTextFieldMask(at: index, text: text)
    }
    
    func setAvailableMasks(_ masks: [String]) {
        customView.setOptions(masks)
    }

    func stripCIDRSuffixFromIPField() {
        customView.stripCIDRSuffixFromIPField()
    }

    func presentShareSheet(text: String) {
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = shareButton
        present(activityController, animated: true)
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
