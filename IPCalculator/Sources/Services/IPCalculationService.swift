import Foundation

protocol IPCalculationUseCase {
    func calculate(ip: UInt32, subnetMask: SubnetMaskModel) -> IPCalculationModel
}

struct IPCalculationService: IPCalculationUseCase {
    func calculate(ip: UInt32, subnetMask: SubnetMaskModel) -> IPCalculationModel {
        let mask = subnetMask.subnet
        let prefix = subnetMask.prefix
        let wildcard = ~mask
        let network = ip & mask
        let broadcast = network | wildcard
        let usableHostMin = prefix == 32 ? ip : network + 1
        let usableHostMax = prefix >= 31 ? ip : broadcast - 1
        let hostCount = prefix >= 31 ? 0 : (1 << (32 - prefix)) - 2

        return IPCalculationModel(
            ip: ip,
            prefix: prefix,
            netmask: mask,
            wildcard: wildcard,
            network: network,
            broadcast: broadcast,
            usableHostMin: usableHostMin,
            usableHostMax: usableHostMax,
            hostCount: hostCount
        )
    }
}
