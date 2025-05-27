import Foundation

struct IPCalculationModel {
    let ip: UInt32
    let prefix: Int
    let netmask: UInt32
    let wildcard: UInt32
    let network: UInt32
    let broadcast: UInt32
    let usableHostMin: UInt32
    let usableHostMax: UInt32
    let hostCount: Int
}
