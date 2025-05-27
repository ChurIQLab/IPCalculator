import Foundation

struct IPCalculatorMaskViewModel {
    let prefix: Int
    let maskString: String

    init(model: SubnetMaskModel, formatter: IPAddressFormattable) {
        prefix = model.prefix
        maskString = formatter.string(from: model.subnet)
    }

    var displayText: String {
        return "\(prefix) - \(maskString)"
    }
}
