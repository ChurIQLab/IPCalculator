import Testing
@testable import IPCalculator

struct SubnetSplitHostsPresenterTests {

    @Test func hostsModeStartsWithOneEmptyRow() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didSelectMode(at: SubnetSplitMode.hosts.rawValue)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.needTexts == [""])
        #expect(model.rows.isEmpty)
        #expect(model.isError == false)
        #expect(model.shareText == nil)
    }

    @Test func placesSixtyTwentyFiveAndTwo() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter(["60", "25", "2"], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.rows.map(\.subnet.network) == ["192.168.10.0/26", "192.168.10.64/27", "192.168.10.96/30"])
        #expect(model.rows.map(\.needNumber) == [1, 2, 3])
        #expect(model.rows.map(\.hostsNeeded) == [60, 25, 2])
        #expect(model.freeRange == "192.168.10.100 – 192.168.10.255")
        #expect(model.freeAddressCount == 156)
    }

    @Test func largestIsPlacedFirstButKeepsItsRowNumber() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter(["2", "25", "60"], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.rows.map(\.needNumber) == [3, 2, 1])
        #expect(model.rows.map(\.subnet.network) == ["192.168.10.0/26", "192.168.10.64/27", "192.168.10.96/30"])
    }

    @Test func emptyRowIsSkippedAndNumbersStay() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter(["60", "", "25"], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.needTexts == ["60", "", "25"])
        #expect(model.rows.map(\.needNumber) == [1, 3])
    }

    @Test(arguments: ["", "0"])
    func rowWithoutAPositiveNumberGivesTheHint(text: String) throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter([text], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.needTexts == [""])
        #expect(model.rows.isEmpty)
        #expect(model.isError == false)
    }

    @Test func needsThatFillTheNetworkLeaveNoFreeSpace() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter(["126", "126"], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.rows.map(\.subnet.network) == ["192.168.10.0/25", "192.168.10.128/25"])
        #expect(model.freeRange == nil)
        #expect(model.freeAddressCount == 0)
        #expect(model.isError == false)
    }

    @Test func oneHostMoreReportsTheRowThatDoesNotFit() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        enter(["126", "127"], into: presenter)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.failedNeedNumber == 1)
        #expect(model.rows.isEmpty)
        #expect(model.shareText == nil)
    }

    @Test func nothingIsSharedWhileARowDoesNotFit() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["200", "60"], into: presenter)

        presenter.didTapShare()

        #expect(view.hostsDisplayed.last?.failedNeedNumber == 2)
        #expect(view.sharedTexts.isEmpty)
    }

    @Test func deletingAMiddleRowRenumbersTheRest() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["60", "25", "2"], into: presenter)

        presenter.didDeleteNeed(at: 1)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.needTexts == ["60", "2"])
        #expect(model.rows.map(\.needNumber) == [1, 2])
        #expect(model.rows.map(\.subnet.network) == ["192.168.10.0/26", "192.168.10.64/30"])
    }

    @Test func deletingTheLastRowLeavesAnEmptyOne() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["60"], into: presenter)

        presenter.didDeleteNeed(at: 0)

        let model = try #require(view.hostsDisplayed.last)
        #expect(model.needTexts == [""])
        #expect(model.rows.isEmpty)
    }

    @Test func ignoresRowIndexOutsideTheList() {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["60"], into: presenter)
        let displayCount = view.hostsDisplayed.count

        presenter.didChangeNeed(at: 1, text: "25")
        presenter.didDeleteNeed(at: -1)

        #expect(view.hostsDisplayed.count == displayCount)
    }

    @Test(arguments: [-1, 2])
    func ignoresUnknownMode(index: Int) {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)

        presenter.didSelectMode(at: index)

        #expect(view.displayed.count == 1)
        #expect(view.hostsDisplayed.isEmpty)
    }

    @Test func sharesTheListOfTheCurrentMode() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["60", "25", "2"], into: presenter)

        presenter.didTapShare()
        presenter.didSelectMode(at: SubnetSplitMode.equal.rawValue)
        presenter.didTapShare()

        #expect(view.sharedTexts.count == 2)
        let hostsText = try #require(view.sharedTexts.first)
        #expect(hostsText.hasPrefix("192.168.10.0/24\n"))
        #expect(hostsText.hasSuffix("""
        192.168.10.96/30
        Hostmin: 192.168.10.97
        Hostmax: 192.168.10.98
        Broadcast: 192.168.10.99
        Hosts: 2
        """))
        #expect(view.sharedTexts.last?.hasPrefix("192.168.10.0/24 → /25\n") == true)
    }

    @Test func switchingBackKeepsTheEnteredRows() throws {
        let view = ViewSpy()
        let presenter = makePresenter(view: view)
        enter(["60", "25"], into: presenter)

        presenter.didSelectMode(at: SubnetSplitMode.equal.rawValue)
        presenter.didSelectMode(at: SubnetSplitMode.hosts.rawValue)

        #expect(view.hostsDisplayed.last?.needTexts == ["60", "25"])
    }
}

private extension SubnetSplitHostsPresenterTests {
    func makePresenter(ip: UInt32 = 0xC0A8_0A00, prefix: Int = 24, view: ViewSpy) -> SubnetSplitPresenter {
        let calculator = IPCalculationService(classDetector: NetworkClassService())
        let network = calculator.calculate(ip: ip, subnetMask: SubnetMaskModel(prefix: prefix))
        let presenter = SubnetSplitPresenter(
            network: network,
            splitter: SubnetSplitService(calculator: calculator),
            formatter: IPAddressFormatter()
        )
        presenter.view = view
        presenter.viewDidLoad()
        return presenter
    }

    /// Switches to the host count mode and fills one row per text, adding rows as a user would.
    func enter(_ texts: [String], into presenter: SubnetSplitPresenter) {
        presenter.didSelectMode(at: SubnetSplitMode.hosts.rawValue)
        for (index, text) in texts.enumerated() {
            if index > 0 {
                presenter.didTapAddNeed()
            }
            presenter.didChangeNeed(at: index, text: text)
        }
    }
}

private final class ViewSpy: SubnetSplitViewProtocol {
    private(set) var displayed: [SubnetSplitViewModel] = []
    private(set) var hostsDisplayed: [SubnetHostsViewModel] = []
    private(set) var sharedTexts: [String] = []

    func display(with model: SubnetSplitViewModel) {
        displayed.append(model)
    }

    func displayHosts(with model: SubnetHostsViewModel) {
        hostsDisplayed.append(model)
    }

    func presentShareSheet(text: String) {
        sharedTexts.append(text)
    }
}
