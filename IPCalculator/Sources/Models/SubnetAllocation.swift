import Foundation

/// One subnet of a split by host count (VLSM) and the requirement it serves.
struct SubnetAllocation {
    /// Position of the requirement in the list passed to the service.
    let requestIndex: Int
    let hostsNeeded: Int
    let subnet: IPCalculationModel
}
