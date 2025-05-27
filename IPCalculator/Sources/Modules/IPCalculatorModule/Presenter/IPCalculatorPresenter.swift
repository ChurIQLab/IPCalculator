import Foundation

protocol IPCalculatorProtocol: AnyObject {
    func viewDidLoad()
    func didTapCalculate(with ip: String)
    func didSelectMask(at index: Int)
}

final class IPCalculatorPresenter {

    // MARK: - Properties

    weak var view: IPCalculatorViewProtocol?

    private let formatter: IPAddressFormattable
    private let ipCalculator: IPCalculationUseCase

    private let maskModel: [SubnetMaskModel]
    private var maskViewModel: [IPCalculatorMaskViewModel] = []

    private var selectedMaskIndex: Int = 0

    // MARK: - Initial

    init(
        formatter: IPAddressFormattable,
        ipCalculator: IPCalculationUseCase,
        maskModel: [SubnetMaskModel]
    ) {
        self.formatter = formatter
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
        view?.updateSelectMaskText(maskViewModel[selectedMaskIndex].displayText)
    }

    func didTapCalculate(with ip: String) {
        let ip = formatter.uint32(from: ip)
        guard let ip = ip else { return }
        let calculateModel = ipCalculator.calculate(ip: ip, subnetMask: maskModel[selectedMaskIndex])
        updateUI(with: calculateModel)
    }
    
    func didSelectMask(at index: Int) {
        guard (0..<maskViewModel.count).contains(index) else { return }
        selectedMaskIndex = index
        view?.updateSelectMaskText(maskViewModel[index].displayText)
    }
}

private extension IPCalculatorPresenter {
    func updateUI(with model: IPCalculationModel) {
        let viewModel = IPCalculatorViewModel(model: model, formatter: formatter)
        view?.display(with: viewModel)
    }
}
