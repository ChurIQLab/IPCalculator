import Foundation

protocol SubnetSplitProtocol: AnyObject {
    func viewDidLoad()
    func didSelectPrefix(at index: Int)
    func didTapShare()
}

final class SubnetSplitPresenter {

    // MARK: - Properties

    weak var view: SubnetSplitViewProtocol?

    private let network: IPCalculationModel
    private let splitter: SubnetSplittable
    private let formatter: IPAddressFormattable

    private let prefixOptions: [IPCalculatorMaskViewModel]
    private var lastResult: SubnetSplitViewModel?

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
        split(at: 0)
    }

    func didSelectPrefix(at index: Int) {
        guard prefixOptions.indices.contains(index) else { return }
        split(at: index)
    }

    func didTapShare() {
        guard let lastResult = lastResult else { return }
        view?.presentShareSheet(text: lastResult.shareText)
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
}
