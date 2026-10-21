import Foundation

protocol SubnetSplitProtocol: AnyObject {
    func viewDidLoad()
    func didSelectMode(at index: Int)
    func didSelectPrefix(at index: Int)
    func didChangeNeed(at index: Int, text: String)
    func didTapAddNeed()
    func didDeleteNeed(at index: Int)
    func didTapShare()
}

final class SubnetSplitPresenter {

    // MARK: - Properties

    weak var view: SubnetSplitViewProtocol?

    private let network: IPCalculationModel
    private let splitter: SubnetSplittable
    private let formatter: IPAddressFormattable

    private let prefixOptions: [IPCalculatorMaskViewModel]
    private var mode: SubnetSplitMode = .equal
    private var selectedPrefixIndex = 0
    /// One entry per requirement row; nil while the row's field is empty.
    private var needs: [Int?] = [nil]

    private var lastResult: SubnetSplitViewModel?
    private var lastHostsResult: SubnetHostsViewModel?

    // MARK: - Initial

    init(
        network: IPCalculationModel,
        splitter: SubnetSplittable,
        formatter: IPAddressFormattable
    ) {
        self.network = network
        self.splitter = splitter
        self.formatter = formatter
        self.prefixOptions = Self.prefixRange(after: network.prefix).map {
            IPCalculatorMaskViewModel(model: SubnetMaskModel(prefix: $0), formatter: formatter)
        }
    }
}

// MARK: - SubnetSplitProtocol

extension SubnetSplitPresenter: SubnetSplitProtocol {
    func viewDidLoad() {
        guard !prefixOptions.isEmpty else { return }
        split(at: selectedPrefixIndex)
    }

    func didSelectMode(at index: Int) {
        guard let newMode = SubnetSplitMode(rawValue: index), !prefixOptions.isEmpty else { return }
        mode = newMode
        switch mode {
        case .equal: split(at: selectedPrefixIndex)
        case .hosts: splitByHosts()
        }
    }

    func didSelectPrefix(at index: Int) {
        guard prefixOptions.indices.contains(index) else { return }
        split(at: index)
    }

    func didChangeNeed(at index: Int, text: String) {
        guard needs.indices.contains(index) else { return }
        // The field takes digits only; zero is not a host count.
        let value = Int(text).flatMap { $0 > 0 ? $0 : nil }
        needs[index] = value
        splitByHosts()
    }

    func didTapAddNeed() {
        needs.append(nil)
        splitByHosts()
    }

    func didDeleteNeed(at index: Int) {
        guard needs.indices.contains(index) else { return }
        needs.remove(at: index)
        // The list always keeps one row to type into.
        if needs.isEmpty {
            needs = [nil]
        }
        splitByHosts()
    }

    func didTapShare() {
        let text: String?
        switch mode {
        case .equal: text = lastResult?.shareText
        case .hosts: text = lastHostsResult?.shareText
        }
        guard let text = text else { return }
        view?.presentShareSheet(text: text)
    }
}

private extension SubnetSplitPresenter {
    /// Prefixes from one bit longer up to the longest that stays within
    /// `SubnetSplitService.maxSubnetCount`, so `tooManySubnets` never reaches the screen.
    static func prefixRange(after prefix: Int) -> [Int] {
        let maxExtraBits = SubnetSplitService.maxSubnetCount.trailingZeroBitCount
        let longest = min(32, prefix + maxExtraBits)
        guard prefix < longest else { return [] }
        return Array((prefix + 1)...longest)
    }

    func split(at index: Int) {
        selectedPrefixIndex = index
        let subnets = (try? splitter.split(
            ip: network.network,
            subnetMask: SubnetMaskModel(prefix: network.prefix),
            into: SubnetMaskModel(prefix: prefixOptions[index].prefix)
        )) ?? []
        let viewModel = SubnetSplitViewModel(
            network: network,
            prefixOptions: prefixOptions,
            selectedPrefixIndex: index,
            subnets: subnets,
            formatter: formatter
        )
        lastResult = viewModel
        view?.display(with: viewModel)
    }

    func splitByHosts() {
        let viewModel = SubnetHostsViewModel(
            network: network,
            needs: needs,
            outcome: hostsOutcome(),
            formatter: formatter
        )
        lastHostsResult = viewModel
        view?.displayHosts(with: viewModel)
    }

    /// Splits by the rows that have a number. The service numbers requirements
    /// by its own input, so its indices are mapped back to the rows.
    func hostsOutcome() -> SubnetHostsViewModel.Outcome {
        let entered = needs.enumerated().compactMap { row, hosts in
            hosts.map { (row: row, hosts: $0) }
        }
        guard !entered.isEmpty else { return .empty }

        do {
            let allocations = try splitter.split(
                ip: network.network,
                subnetMask: SubnetMaskModel(prefix: network.prefix),
                hostCounts: entered.map(\.hosts)
            )
            return .placed(allocations.map { (needNumber: entered[$0.requestIndex].row + 1, allocation: $0) })
        } catch SubnetSplitError.notEnoughSpace(let requestIndex, let hostCount) {
            return .notEnoughSpace(needNumber: entered[requestIndex].row + 1, hostCount: hostCount)
        } catch {
            return .empty
        }
    }
}
