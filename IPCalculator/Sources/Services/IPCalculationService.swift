import Foundation

protocol IPCalculationUseCase {
    func calculate(ip: UInt32, subnetMask: SubnetMaskModel) -> IPCalculationModel
}

struct IPCalculationService: IPCalculationUseCase {

    private let classDetector: NetworkClassDetectable

    init(classDetector: NetworkClassDetectable) {
        self.classDetector = classDetector
    }

    func calculate(ip: UInt32, subnetMask: SubnetMaskModel) -> IPCalculationModel {
        let mask = subnetMask.subnet
        let prefix = subnetMask.prefix
        let wildcard = ~mask
        let network = ip & mask
        let broadcast = network | wildcard
        // /31 (RFC 3021 point-to-point) and /32 (host route) have no separate
        // network and broadcast addresses, so every address in the block is usable.
        let reservesNetworkAndBroadcast = prefix <= 30
        let blockSize = 1 << (32 - prefix)
        let usableHostMin = reservesNetworkAndBroadcast ? network + 1 : network
        let usableHostMax = reservesNetworkAndBroadcast ? broadcast - 1 : broadcast
        let hostCount = reservesNetworkAndBroadcast ? blockSize - 2 : blockSize

        return IPCalculationModel(
            ip: ip,
            prefix: prefix,
            netmask: mask,
            wildcard: wildcard,
            network: network,
            broadcast: broadcast,
            usableHostMin: usableHostMin,
            usableHostMax: usableHostMax,
            hostCount: hostCount,
            networkClass: classDetector.networkClass(for: ip),
            networkType: classDetector.networkType(for: ip)
        )
    }
}
