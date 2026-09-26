import Foundation

struct SubnetSplitViewModel {
    let networkText: String
    let prefixOptions: [String]
    let selectedPrefixIndex: Int
    let summaryText: String
    let rows: [SubnetSplitRowViewModel]
    let shareText: String

    init(
        network: IPCalculationModel,
        prefixOptions: [IPCalculatorMaskViewModel],
        selectedPrefixIndex: Int,
        subnets: [IPCalculationModel],
        formatter: IPAddressFormattable
    ) {
        networkText = "\(formatter.string(from: network.network))/\(network.prefix)"
        self.prefixOptions = prefixOptions.map(\.displayText)
        self.selectedPrefixIndex = selectedPrefixIndex
        rows = subnets.map { SubnetSplitRowViewModel(model: $0, formatter: formatter) }
        summaryText = String(format: UIConstants.Text.splitSummary, subnets.count, subnets.first?.hostCount ?? 0)

        let newPrefix = prefixOptions.indices.contains(selectedPrefixIndex)
            ? prefixOptions[selectedPrefixIndex].prefix
            : network.prefix
        let header = "\(networkText) → /\(newPrefix)\n\(summaryText)"
        shareText = ([header] + rows.map(\.shareText)).joined(separator: "\n\n")
    }
}
