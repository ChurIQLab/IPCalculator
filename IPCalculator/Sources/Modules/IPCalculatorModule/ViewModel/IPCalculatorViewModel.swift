import Foundation

struct IPCalculatorViewModel {
    let rows: [IPCalculatorTableViewModel]

    init(model: IPCalculationModel, formatter: IPAddressFormattable) {
        rows = [
            .init(title: "Address", value: formatter.string(from: model.ip)),
            .init(title: "Address (bin)", value: formatter.binaryString(from: model.ip), isMonospaced: true),
            .init(title: "Netmask", value: formatter.string(from: model.netmask)),
            .init(title: "Netmask (bin)", value: formatter.binaryString(from: model.netmask), isMonospaced: true),
            .init(title: "Wildcard", value: formatter.string(from: model.wildcard)),
            .init(title: "Network", value: formatter.string(from: model.network)),
            .init(title: "Broadcast", value: formatter.string(from: model.broadcast)),
            .init(title: "Hostmin", value: formatter.string(from: model.usableHostMin)),
            .init(title: "Hostmax", value: formatter.string(from: model.usableHostMax)),
            .init(title: "Hosts", value: model.hostCount.description),
            .init(title: "Class", value: model.networkClass.rawValue),
            .init(title: "Type", value: model.networkType.rawValue)
        ]
    }
}
