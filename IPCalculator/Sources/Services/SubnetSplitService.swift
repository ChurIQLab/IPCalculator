import Foundation

protocol SubnetSplittable {
    func split(ip: UInt32, subnetMask: SubnetMaskModel, into newMask: SubnetMaskModel) throws -> [IPCalculationModel]
    func split(ip: UInt32, subnetMask: SubnetMaskModel, hostCounts: [Int]) throws -> [SubnetAllocation]
}

struct SubnetSplitService: SubnetSplittable {

    /// Upper bound for an equal split: a /8 into /30 would be 4 194 304 subnets,
    /// too many to keep in memory or share as text.
    static let maxSubnetCount = 4096

    /// Longest prefix given to a host requirement. Like classic VLSM
    /// calculators, even one or two hosts get a /30 with network and broadcast
    /// addresses: a /31 works only on point-to-point router links.
    private static let longestHostPrefix = 30

    private let calculator: IPCalculationUseCase

    init(calculator: IPCalculationUseCase) {
        self.calculator = calculator
    }

    // MARK: - Equal parts

    func split(ip: UInt32, subnetMask: SubnetMaskModel, into newMask: SubnetMaskModel) throws -> [IPCalculationModel] {
        guard newMask.prefix > subnetMask.prefix, newMask.prefix <= 32 else {
            throw SubnetSplitError.invalidPrefix
        }
        let subnetCount = 1 << (newMask.prefix - subnetMask.prefix)
        guard subnetCount <= Self.maxSubnetCount else {
            throw SubnetSplitError.tooManySubnets
        }

        let network = ip & subnetMask.subnet
        // The last subnet ends at the network's broadcast, so the sum never
        // passes UInt32.max, even for 255.255.255.0/24.
        return (0..<subnetCount).map { index in
            let subnetNetwork = network + UInt32(index) << (32 - newMask.prefix)
            return calculator.calculate(ip: subnetNetwork, subnetMask: newMask)
        }
    }

    // MARK: - Host counts (VLSM)

    func split(ip: UInt32, subnetMask: SubnetMaskModel, hostCounts: [Int]) throws -> [SubnetAllocation] {
        guard hostCounts.allSatisfy({ $0 > 0 }) else {
            throw SubnetSplitError.invalidHostCount
        }

        // Largest first: every block is then aligned to its own size, and the
        // requirements fit whenever their blocks add up to the network size.
        let requests = hostCounts.enumerated().sorted {
            $0.element != $1.element ? $0.element > $1.element : $0.offset < $1.offset
        }

        // UInt64, because the end of 255.255.255.0/24 is 2^32.
        let networkStart = UInt64(ip & subnetMask.subnet)
        let networkEnd = networkStart + blockSize(prefix: subnetMask.prefix)
        var nextFree = networkStart

        return try requests.map { request in
            guard let prefix = hostPrefix(for: request.element),
                  prefix >= subnetMask.prefix,
                  nextFree + blockSize(prefix: prefix) <= networkEnd else {
                throw SubnetSplitError.notEnoughSpace(requestIndex: request.offset, hostCount: request.element)
            }
            let subnet = calculator.calculate(ip: UInt32(nextFree), subnetMask: SubnetMaskModel(prefix: prefix))
            nextFree += blockSize(prefix: prefix)
            return SubnetAllocation(requestIndex: request.offset, hostsNeeded: request.element, subnet: subnet)
        }
    }
}

// MARK: - Private

private extension SubnetSplitService {
    func blockSize(prefix: Int) -> UInt64 {
        return UInt64(1) << (32 - prefix)
    }

    /// The longest prefix whose block, minus network and broadcast, holds
    /// `hosts`; nil when no IPv4 block is large enough.
    func hostPrefix(for hosts: Int) -> Int? {
        return (0...Self.longestHostPrefix).reversed().first { blockSize(prefix: $0) - 2 >= UInt64(hosts) }
    }
}
