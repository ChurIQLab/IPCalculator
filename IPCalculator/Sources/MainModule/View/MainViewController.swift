import UIKit

protocol MainViewProtocol: AnyObject {
    func display(with model: MainViewModel)
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

extension MainViewController: MainViewProtocol {
    func display(with model: MainViewModel) {
        customView.configuration(with: model)
    }
}
