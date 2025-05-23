import UIKit

protocol MainModuleFactoryProtocol: AnyObject {
    func make() -> UIViewController
}

final class MainModuleFactory: MainModuleFactoryProtocol {
    func make() -> UIViewController {
        let model = MainModel()
        let presenter = MainPresenter(model: model)
        let view = MainViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
