import Testing
@testable import IPCalculator

struct IPCalculatorPresenterTests {

    @Test func sharesTextOfLastCalculation() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didTapCalculate(with: "10.0.0.1/8")
        presenter.didTapCalculate(with: "192.168.1.10/24")
        presenter.didTapShare()

        #expect(view.sharedTexts.count == 1)
        #expect(view.sharedTexts.first?.hasPrefix("192.168.1.10/24\n\nAddress: 192.168.1.10\n") == true)
    }

    @Test func ignoresShareBeforeFirstCalculation() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didTapShare()

        #expect(view.sharedTexts.isEmpty)
    }

    @Test func opensSplitForLastCalculation() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didTapCalculate(with: "10.0.0.1/8")
        presenter.didTapCalculate(with: "192.168.1.10/24")
        presenter.didTapSplit()

        #expect(view.splitNetworks.map(\.network) == [0xC0A8_0100])
        #expect(view.splitNetworks.map(\.prefix) == [24])
    }

    @Test(arguments: [(input: "10.0.0.1/31", opens: true), (input: "10.0.0.1/32", opens: false)])
    func opensSplitUpToSlash31(input: String, opens: Bool) {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didTapCalculate(with: input)
        presenter.didTapSplit()

        #expect(view.splitNetworks.isEmpty != opens)
    }

    @Test func ignoresSplitBeforeFirstCalculation() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didTapSplit()

        #expect(view.splitNetworks.isEmpty)
    }
}

private extension IPCalculatorPresenterTests {
    func makePresenter(view: ViewSpy) -> IPCalculatorPresenter {
        let presenter = IPCalculatorPresenter(
            formatter: IPAddressFormatter(),
            validator: IPAddressValidator(),
            ipCalculator: IPCalculationService(classDetector: NetworkClassService()),
            maskModel: SubnetMaskModel.default
        )
        presenter.view = view
        presenter.viewDidLoad()
        return presenter
    }
}

private final class ViewSpy: IPCalculatorViewProtocol {
    private(set) var sharedTexts: [String] = []
    private(set) var splitNetworks: [IPCalculationModel] = []

    func display(with model: IPCalculatorViewModel) {}
    func updateSelectMask(at index: Int, text: String) {}
    func setAvailableMasks(_ masks: [String]) {}
    func stripCIDRSuffixFromIPField() {}

    func presentShareSheet(text: String) {
        sharedTexts.append(text)
    }

    func showSubnetSplit(for model: IPCalculationModel) {
        splitNetworks.append(model)
    }
}
