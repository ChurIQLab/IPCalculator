import Foundation

enum SubnetSplitError: Error, Equatable {
    /// The new prefix is not longer than the network prefix, or is past /32.
    case invalidPrefix
    /// Splitting would give more than `SubnetSplitService.maxSubnetCount` subnets.
    case tooManySubnets
    /// A host requirement is zero or negative.
    case invalidHostCount
    /// The requirement at `requestIndex` does not fit into the space left in the
    /// network. Requirements are placed largest first, so every larger one fits.
    case notEnoughSpace(requestIndex: Int, hostCount: Int)
}
