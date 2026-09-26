import Testing
@testable import IPCalculator

struct SubnetSplitPresenterTests {

    @Test func opensWithTwoHalvesOfTheNetwork() throws {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0xC0A8_0100, prefix: 24, view: view)

        presenter.viewDidLoad()

        let model = try #require(view.displayed.last)
        #expect(model.networkText == "192.168.1.0/24")
        #expect(model.selectedPrefixIndex == 0)
        #expect(model.rows.map(\.network) == ["192.168.1.0/25", "192.168.1.128/25"])
    }

    @Test(arguments: [
        (prefix: 8, first: 9, last: 20),
        (prefix: 20, first: 21, last: 32),
        (prefix: 21, first: 22, last: 32),
        (prefix: 31, first: 32, last: 32)
    ])
    func offersPrefixesUpToTwelveBitsLongerOrSlash32(prefix: Int, first: Int, last: Int) throws {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0x0A00_0000, prefix: prefix, view: view)

        presenter.viewDidLoad()

        let options = try #require(view.displayed.last).prefixOptions
        #expect(options.first?.hasPrefix("\(first) - ") == true)
        #expect(options.last?.hasPrefix("\(last) - ") == true)
        #expect(options.count == last - first + 1)
    }

    @Test func slash32ShowsNothing() {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0x0A00_0001, prefix: 32, view: view)

        presenter.viewDidLoad()
        presenter.didSelectPrefix(at: 0)
        presenter.didTapShare()

        #expect(view.displayed.isEmpty)
        #expect(view.sharedTexts.isEmpty)
    }

    @Test func selectingSlash26GivesFourQuarters() throws {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0xC0A8_0100, prefix: 24, view: view)
        presenter.viewDidLoad()

        presenter.didSelectPrefix(at: 1)

        let model = try #require(view.displayed.last)
        #expect(model.selectedPrefixIndex == 1)
        #expect(model.rows.map(\.network) == [
            "192.168.1.0/26", "192.168.1.64/26", "192.168.1.128/26", "192.168.1.192/26"
        ])
        #expect(model.rows.map(\.hostRange) == [
            "192.168.1.1 – 192.168.1.62", "192.168.1.65 – 192.168.1.126",
            "192.168.1.129 – 192.168.1.190", "192.168.1.193 – 192.168.1.254"
        ])
        #expect(model.rows.map(\.broadcast) == ["192.168.1.63", "192.168.1.127", "192.168.1.191", "192.168.1.255"])
    }

    @Test func longestOfferedPrefixReachesTheSubnetLimit() throws {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0x0A00_0000, prefix: 8, view: view)
        presenter.viewDidLoad()

        presenter.didSelectPrefix(at: 11)

        let rows = try #require(view.displayed.last).rows
        #expect(rows.count == SubnetSplitService.maxSubnetCount)
        #expect(rows.last?.network == "10.255.240.0/20")
    }

    @Test(arguments: [-1, 8])
    func ignoresIndexOutsideTheOptions(index: Int) {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0xC0A8_0100, prefix: 24, view: view)
        presenter.viewDidLoad()

        presenter.didSelectPrefix(at: index)

        #expect(view.displayed.count == 1)
    }

    @Test func sharesTheCurrentSplit() throws {
        let view = ViewSpy()
        let presenter = makePresenter(ip: 0xC0A8_0100, prefix: 24, view: view)
        presenter.viewDidLoad()
        presenter.didSelectPrefix(at: 1)

        presenter.didTapShare()

        let text = try #require(view.sharedTexts.last)
        #expect(view.sharedTexts.count == 1)
        #expect(text.hasPrefix("192.168.1.0/24 → /26\n"))
        #expect(text.hasSuffix("""
        192.168.1.192/26
        Hostmin: 192.168.1.193
        Hostmax: 192.168.1.254
        Broadcast: 192.168.1.255
        Hosts: 62
        """))
    }
}

private extension SubnetSplitPresenterTests {
    func makePresenter(ip: UInt32, prefix: Int, view: ViewSpy) -> SubnetSplitPresenter {
        let calculator = IPCalculationService(classDetector: NetworkClassService())
        let network = calculator.calculate(ip: ip, subnetMask: SubnetMaskModel(prefix: prefix))
        let presenter = SubnetSplitPresenter(
            network: network,
            splitter: SubnetSplitService(calculator: calculator),
            formatter: IPAddressFormatter()
        )
        presenter.view = view
        return presenter
    }
}

private final class ViewSpy: SubnetSplitViewProtocol {
    private(set) var displayed: [SubnetSplitViewModel] = []
    private(set) var sharedTexts: [String] = []

    func display(with model: SubnetSplitViewModel) {
        displayed.append(model)
    }

    func presentShareSheet(text: String) {
        sharedTexts.append(text)
    }
}
