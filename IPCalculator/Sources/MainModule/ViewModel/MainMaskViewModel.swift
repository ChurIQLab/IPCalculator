import Foundation

struct MainMaskViewModel {
    let displayText: String

    init(model: SubnetMaskModel) {
        self.displayText = "\(model.prefix) - \(model.subnet)"
    }
}
