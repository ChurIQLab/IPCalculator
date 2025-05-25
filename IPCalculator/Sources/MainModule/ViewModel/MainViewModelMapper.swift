import Foundation

func mapToViewModels(from result: IPCalculationModel) -> [MainTableViewModel] {
    return [
        .init(title: "Address", value: result.address),
        .init(title: "Netmask", value: result.netmask),
        .init(title: "Wildcard", value: result.wildcard),
        .init(title: "Network", value: result.network),
        .init(title: "Broadcast", value: result.broadcast),
        .init(title: "Hostmin", value: result.hosMin),
        .init(title: "Hostmax", value: result.hostMax),
        .init(title: "Hosts", value: result.hosts),

    ]
}
