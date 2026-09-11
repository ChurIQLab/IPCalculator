import Foundation

protocol IPCalculatorProtocol: AnyObject {
    func viewDidLoad()
    func didTapCalculate(with ip: String)
    func didSelectMask(at index: Int)
    func didTapShare()
}

final class IPCalculatorPresenter {

    // MARK: - Properties

    weak var view: IPCalculatorViewProtocol?

    private let formatter: IPAddressFormattable
    private let validator: IPAddressValidatable
    private let ipCalculator: IPCalculationUseCase

    private let maskModel: [SubnetMaskModel]
    private var maskViewModel: [IPCalculatorMaskViewModel] = []

    private var selectedMaskIndex: Int = 0
    private var lastResult: IPCalculatorViewModel?

    // MARK: - Initial

    init(
        formatter: IPAddressFormattable,
        validator: IPAddressValidatable,
        ipCalculator: IPCalculationUseCase,
        maskModel: [SubnetMaskModel]
    ) {
        self.formatter = formatter
        self.validator = validator
        self.ipCalculator = ipCalculator
        self.maskModel = maskModel
    }
}

// MARK: - MainPresenterProtocol

extension IPCalculatorPresenter: IPCalculatorProtocol {
    func viewDidLoad() {
        guard !maskModel.isEmpty else { return }
        maskViewModel = maskModel.map { IPCalculatorMaskViewModel(model: $0, formatter: formatter) }
        view?.setAvailableMasks(maskViewModel.map(\.displayText))
        view?.updateSelectMask(at: selectedMaskIndex, text: maskViewModel[selectedMaskIndex].displayText)
    }

    func didTapCalculate(with ip: String) {
        guard let components = validator.cidrComponents(from: ip),
              let ipValue = formatter.uint32(from: components.address) else { return }

        if let prefix = components.prefix,
           let index = maskModel.firstIndex(where: { $0.prefix == prefix }) {
            selectMask(at: index)
        }

        let calculateModel = ipCalculator.calculate(ip: ipValue, subnetMask: maskModel[selectedMaskIndex])
        updateUI(with: calculateModel)
    }

    func didSelectMask(at index: Int) {
        guard (0..<maskViewModel.count).contains(index) else { return }
        selectMask(at: index)
        view?.stripCIDRSuffixFromIPField()
    }

    func didTapShare() {
        guard let lastResult = lastResult else { return }
        view?.presentShareSheet(text: lastResult.shareText)
    }
}

private extension IPCalculatorPresenter {
    func selectMask(at index: Int) {
        selectedMaskIndex = index
        view?.updateSelectMask(at: index, text: maskViewModel[index].displayText)
    }

    func updateUI(with model: IPCalculationModel) {
        let viewModel = IPCalculatorViewModel(model: model, formatter: formatter)
        lastResult = viewModel
        view?.display(with: viewModel)
    }
}
