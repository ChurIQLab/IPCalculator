import Foundation

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class MainPresenter {

    // MARK: - Properties

    weak var view: MainViewProtocol?

    private let model: MainModel

    // MARK: - Initial

    init(model: MainModel) {
        self.model = model
    }
}

// MARK: - MainPresenterProtocol

extension MainPresenter: MainPresenterProtocol {
    func viewDidLoad() {
        let viewModel = MainViewModel()
        view?.display(with: viewModel)
    }
}
