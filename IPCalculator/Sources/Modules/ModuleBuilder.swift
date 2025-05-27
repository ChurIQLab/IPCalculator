import UIKit

protocol Builder: AnyObject {
    func buildIpCalculatorModule() -> UIViewController
}

final class ModuleBuilder: Builder {
    func buildIpCalculatorModule() -> UIViewController {
        let formatter = IPAddressFormatter()
        let ipCalculator = IPCalculationService()
        let maskModel = SubnetMaskModel.default
        let presenter = IPCalculatorPresenter(
            formatter: formatter,
            ipCalculator: ipCalculator,
            maskModel: maskModel
        )
        let view = IPCalculatorViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
