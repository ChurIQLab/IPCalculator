import UIKit

protocol SubnetSplitViewProtocol: AnyObject {
    func display(with model: SubnetSplitViewModel)
    func presentShareSheet(text: String)
}

final class SubnetSplitViewController: UIViewController {

    // MARK: - Properties

    private let presenter: SubnetSplitProtocol
    private lazy var customView = SubnetSplitView()
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

        setupNavigationBar()

        customView.delegate = self
        presenter.viewDidLoad()
    }

    // MARK: - Initial

    init(presenter: SubnetSplitProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension SubnetSplitViewController {
    func setupNavigationBar() {
        title = UIConstants.Text.splitTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = shareButton
    }
}

// MARK: - SubnetSplitViewProtocol

extension SubnetSplitViewController: SubnetSplitViewProtocol {
    func display(with model: SubnetSplitViewModel) {
        customView.configuration(with: model)
    }

    func presentShareSheet(text: String) {
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = shareButton
        present(activityController, animated: true)
    }
}

// MARK: - Delegate

extension SubnetSplitViewController: SubnetSplitViewDelegate {
    func didSelectPrefix(at index: Int) {
        presenter.didSelectPrefix(at: index)
    }
}
