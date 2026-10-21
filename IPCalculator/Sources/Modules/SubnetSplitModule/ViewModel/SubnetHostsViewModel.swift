import Foundation

struct SubnetHostsViewModel {

    /// What the presenter got from the split by host count.
    enum Outcome {
        /// No requirement entered yet.
        case empty
        /// Every requirement placed; `needNumber` is 1-based, in placement order.
        case placed([(needNumber: Int, allocation: SubnetAllocation)])
        /// The requirement `needNumber` (1-based) does not fit; nothing is placed.
        case notEnoughSpace(needNumber: Int, hostCount: Int)
    }

    let networkText: String
    /// Field texts, one per requirement row; empty for a row without a number.
    let needTexts: [String]
    let rows: [SubnetHostsRowViewModel]
    /// The requirement that does not fit, if any.
    let failedNeedNumber: Int?
    /// First and last free address after the placed subnets, nil when none is free.
    let freeRange: String?
    let freeAddressCount: UInt64
    let summaryText: String
    /// Nil while there is nothing to share: no requirement or one that does not fit.
    let shareText: String?

    var isError: Bool {
        return failedNeedNumber != nil
    }

    init(network: IPCalculationModel, needs: [Int?], outcome: Outcome, formatter: IPAddressFormattable) {
        networkText = "\(formatter.string(from: network.network))/\(network.prefix)"
        needTexts = needs.map { $0.map(String.init) ?? "" }

        switch outcome {
        case .empty:
            rows = []
            failedNeedNumber = nil
            freeRange = nil
            freeAddressCount = 0
            summaryText = UIConstants.Text.splitHostsHint
            shareText = nil

        case .placed(let placed):
            rows = placed.map {
                SubnetHostsRowViewModel(
                    needNumber: $0.needNumber,
                    hostsNeeded: $0.allocation.hostsNeeded,
                    subnet: SubnetSplitRowViewModel(model: $0.allocation.subnet, formatter: formatter)
                )
            }
            failedNeedNumber = nil

            // Subnets sit back to back from the network start, so the free space
            // is one block from the end of the last subnet to the broadcast.
            // UInt64, because the end of 255.255.255.0/24 is 2^32.
            let networkEnd = UInt64(network.broadcast) + 1
            let usedEnd = placed.map { UInt64($0.allocation.subnet.broadcast) + 1 }.max() ?? UInt64(network.network)
            freeAddressCount = networkEnd - usedEnd
            if freeAddressCount > 0 {
                let range = "\(formatter.string(from: UInt32(usedEnd))) – \(formatter.string(from: network.broadcast))"
                freeRange = range
                summaryText = String(format: UIConstants.Text.splitFreeSpace, range, freeAddressCount.description)
            } else {
                freeRange = nil
                summaryText = UIConstants.Text.splitNoFreeSpace
            }
            let header = "\(networkText)\n\(summaryText)"
            shareText = ([header] + rows.map(\.shareText)).joined(separator: "\n\n")

        case .notEnoughSpace(let needNumber, let hostCount):
            rows = []
            failedNeedNumber = needNumber
            freeRange = nil
            freeAddressCount = 0
            summaryText = String(format: UIConstants.Text.splitNotEnoughSpace, needNumber, hostCount)
            shareText = nil
        }
    }
}
