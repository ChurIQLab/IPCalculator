import UIKit

protocol Builder: AnyObject {
    func buildIpCalculatorModule() -> UIViewController
}

final class ModuleBuilder: Builder {
    func buildIpCalculatorModule() -> UIViewController {
        let formatter = IPAddressFormatter()
        let networkClassDetector = NetworkClassService()
        let ipCalculator = IPCalculationService(classDetector: networkClassDetector)
        let ipValidator = IPAddressValidator()
        let maskModel = SubnetMaskModel.default
        let presenter = IPCalculatorPresenter(
            formatter: formatter,
            validator: ipValidator,
            ipCalculator: ipCalculator,
            maskModel: maskModel
        )
        let view = IPCalculatorViewController(presenter: presenter, ipValidator: ipValidator)
        presenter.view = view
        return view
    }
}
