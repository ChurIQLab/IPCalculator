import Foundation

struct SubnetHostsRowViewModel {
    /// 1-based position of the requirement in the list the user entered.
    let needNumber: Int
    let hostsNeeded: Int
    let subnet: SubnetSplitRowViewModel

    var needText: String {
        return String(format: UIConstants.Text.splitNeedLine, needNumber, hostsNeeded)
    }

    var shareText: String {
        return "\(needText)\n\(subnet.shareText)"
    }
}
