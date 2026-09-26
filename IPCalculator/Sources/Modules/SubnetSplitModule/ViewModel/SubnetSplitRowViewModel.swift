import Foundation

struct SubnetSplitRowViewModel {
    let network: String
    let hostMin: String
    let hostMax: String
    let broadcast: String
    let hosts: String

    init(model: IPCalculationModel, formatter: IPAddressFormattable) {
        network = "\(formatter.string(from: model.network))/\(model.prefix)"
        hostMin = formatter.string(from: model.usableHostMin)
        hostMax = formatter.string(from: model.usableHostMax)
        broadcast = formatter.string(from: model.broadcast)
        hosts = model.hostCount.description
    }

    var hostRange: String {
        return "\(hostMin) – \(hostMax)"
    }

    /// Values in copy and share order; the labels are networking terms and stay in English.
    var items: [IPCalculatorTableViewModel] {
        return [
            .init(title: "Network", value: network),
            .init(title: "Hostmin", value: hostMin),
            .init(title: "Hostmax", value: hostMax),
            .init(title: "Broadcast", value: broadcast),
            .init(title: "Hosts", value: hosts)
        ]
    }

    /// The network on the first line, then the other values as `Title: value`.
    var shareText: String {
        let lines = items.dropFirst().map { "\($0.title): \($0.value)" }
        return ([network] + lines).joined(separator: "\n")
    }
}
