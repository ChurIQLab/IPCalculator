import UIKit

protocol Builder: AnyObject {
    func buildIpCalculatorModule() -> UIViewController
    func buildSubnetSplitModule(network: IPCalculationModel) -> UIViewController
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
        let view = IPCalculatorViewController(presenter: presenter, ipValidator: ipValidator, builder: self)
        presenter.view = view
        return view
    }

    func buildSubnetSplitModule(network: IPCalculationModel) -> UIViewController {
        let formatter = IPAddressFormatter()
        let networkClassDetector = NetworkClassService()
        let ipCalculator = IPCalculationService(classDetector: networkClassDetector)
        let splitter = SubnetSplitService(calculator: ipCalculator)
        let presenter = SubnetSplitPresenter(
            network: network,
            splitter: splitter,
            formatter: formatter
        )
        let view = SubnetSplitViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
