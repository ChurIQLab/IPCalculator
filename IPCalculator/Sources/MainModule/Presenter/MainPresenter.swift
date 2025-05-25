import Foundation

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapCalculate(with ip: String)
    func didSelectMask(at index: Int)
}

final class MainPresenter {

    // MARK: - Properties

    weak var view: MainViewProtocol?

    private let maskModel: [SubnetMaskModel]
    private var maskViewModel: [MainMaskViewModel] = []

    private(set) var selectedMaskIndex: Int = 0

    // MARK: - Initial

    init(maskModel: [SubnetMaskModel]) {
        self.maskModel = maskModel
        maskViewModel = maskModel.map { MainMaskViewModel(model: $0) }
    }
}

// MARK: - MainPresenterProtocol

extension MainPresenter: MainPresenterProtocol {
    func viewDidLoad() {
        view?.setAvailableMasks(maskViewModel.map(\.displayText))
        view?.updateSelectMaskText(maskViewModel[selectedMaskIndex].displayText)

        let ipCalculationModel = IPCalculationModel(
            address: "0.0.0.0",
            netmask: "0.0.0.0",
            wildcard: "0.0.0.0",
            network: "0.0.0.0",
            broadcast: "0.0.0.0",
            hosMin: "0.0.0.0",
            hostMax: "0.0.0.0",
            hosts: "0.0.0.0"
        )

        updateUI(with: ipCalculationModel)
    }

    func didTapCalculate(with ip: String) {
        print("DEBUG: Tap IP Calculate: \(ip)")
    }
    
    func didSelectMask(at index: Int) {
        guard (0..<maskViewModel.count).contains(index) else { return }
        selectedMaskIndex = index
        view?.updateSelectMaskText(maskViewModel[index].displayText)
    }
}

private extension MainPresenter {
    func updateUI(with result: IPCalculationModel) {
        let rows = mapToViewModels(from: result)
        let viewModel = MainViewModel(selectedMaskIndex: selectedMaskIndex, resultRows: rows)
        view?.display(with: viewModel)
    }
}
