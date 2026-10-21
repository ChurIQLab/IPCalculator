import UIKit

protocol SubnetSplitViewDelegate: AnyObject {
    func didSelectMode(at index: Int)
    func didSelectPrefix(at index: Int)
    func didChangeNeed(at index: Int, text: String)
    func didTapAddNeed()
    func didDeleteNeed(at index: Int)
}

final class SubnetSplitView: UIView {

    // MARK: - Properties

    weak var delegate: SubnetSplitViewDelegate?

    private var mode: SubnetSplitMode = .equal
    private var equalRows: [SubnetSplitRowViewModel] = []
    private var needTexts: [String] = []
    private var hostsRows: [SubnetHostsRowViewModel] = []

    private enum HostsSection: Int, CaseIterable {
        case needs
        case subnets
    }

    // MARK: - Outlets

    private let networkLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .semibold,
                              textStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [UIConstants.Text.splitModeEqual, UIConstants.Text.splitModeHosts])
        control.selectedSegmentIndex = SubnetSplitMode.equal.rawValue
        control.addAction(
            UIAction { [weak self, weak control] _ in
                guard let index = control?.selectedSegmentIndex else { return }
                self?.endEditing(true)
                self?.delegate?.didSelectMode(at: index)
            },
            for: .valueChanged
        )
        return control
    }()

    private let prefixLabel: UILabel = {
        let label = UILabel()
        label.text = UIConstants.Text.splitPrefixLabel
        label.textColor = .label
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        return label
    }()

    private let prefixButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "chevron.up.chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = UIConstants.Spacing.stackViewSpacing
        configuration.baseForegroundColor = .label
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = UIConstants.CornerRadius.button

        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        button.showsMenuAsPrimaryAction = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.Size.textFieldHeight).isActive = true
        return button
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.applyScaledFont(size: UIConstants.FontSize.small,
                              weight: .regular,
                              textStyle: .subheadline)
        return label
    }()

    /// Hidden subviews of a stack view take no space, so the prefix menu
    /// disappears cleanly in the host count mode.
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [modeControl, prefixLabel, prefixButton, summaryLabel])
        stack.axis = .vertical
        stack.spacing = UIConstants.Spacing.labelToTextField
        stack.setCustomSpacing(UIConstants.Spacing.screenVertial, after: modeControl)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)

        table.register(SubnetSplitTableViewCell.self,
                       forCellReuseIdentifier: SubnetSplitTableViewCell.identifier)
        table.register(SubnetNeedTableViewCell.self,
                       forCellReuseIdentifier: SubnetNeedTableViewCell.identifier)
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: Self.addNeedCellIdentifier)
        table.register(UITableViewHeaderFooterView.self,
                       forHeaderFooterViewReuseIdentifier: Self.headerIdentifier)

        table.dataSource = self
        table.delegate = self

        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UIConstants.Size.subnetCellEstimatedHeight
        table.keyboardDismissMode = .onDrag

        table.layer.cornerRadius = UIConstants.CornerRadius.normal
        table.layer.borderWidth = UIConstants.Size.borderWidth
        table.layer.borderColor = UIColor.systemGray5.cgColor

        table.separatorInset = .zero
        table.separatorColor = .systemGray5

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private static let addNeedCellIdentifier = "SubnetAddNeedCell"
    private static let headerIdentifier = "SubnetSplitHeader"

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
    }
}

// MARK: - Setup

private extension SubnetSplitView {
    func setupView() {
        backgroundColor = .systemBackground
    }

    func setupHierarchy() {
        addSubview(networkLabel)
        addSubview(controlsStackView)
        addSubview(tableView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            networkLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                              constant: UIConstants.Spacing.labelToTextField),
            networkLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                  constant: UIConstants.Spacing.screenHorizontal),
            networkLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                   constant: -UIConstants.Spacing.screenHorizontal),
            controlsStackView.topAnchor.constraint(equalTo: networkLabel.bottomAnchor,
                                                   constant: UIConstants.Spacing.labelToTextField),
            controlsStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                       constant: UIConstants.Spacing.screenHorizontal),
            controlsStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                        constant: -UIConstants.Spacing.screenHorizontal),
            tableView.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor,
                                           constant: UIConstants.Spacing.screenVertial),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: UIConstants.Spacing.screenHorizontal),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -UIConstants.Spacing.screenHorizontal),
            // Follows the keyboard, so the requirement being typed stays visible.
            tableView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor,
                                              constant: -UIConstants.Spacing.screenVertial)
        ])
    }

    func makePrefixMenu(options: [String], selectedIndex: Int) -> UIMenu {
        let actions = options.enumerated().map { index, option in
            UIAction(title: option, state: index == selectedIndex ? .on : .off) { [weak self] _ in
                self?.delegate?.didSelectPrefix(at: index)
            }
        }
        return UIMenu(children: actions)
    }

    func showControls(for mode: SubnetSplitMode) {
        modeControl.selectedSegmentIndex = mode.rawValue
        prefixLabel.isHidden = mode != .equal
        prefixButton.isHidden = mode != .equal
    }
}

// MARK: - Public func

extension SubnetSplitView {
    func configuration(with model: SubnetSplitViewModel) {
        mode = .equal
        showControls(for: .equal)
        networkLabel.text = model.networkText
        summaryLabel.text = model.summaryText
        summaryLabel.textColor = .secondaryLabel

        if model.prefixOptions.indices.contains(model.selectedPrefixIndex) {
            prefixButton.configuration?.title = model.prefixOptions[model.selectedPrefixIndex]
        }
        prefixButton.menu = makePrefixMenu(options: model.prefixOptions, selectedIndex: model.selectedPrefixIndex)

        equalRows = model.rows
        tableView.reloadData()
        if !equalRows.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    func configuration(with model: SubnetHostsViewModel) {
        let wasHostsMode = mode == .hosts
        let previousNeedCount = needTexts.count

        mode = .hosts
        showControls(for: .hosts)
        networkLabel.text = model.networkText
        summaryLabel.text = model.summaryText
        summaryLabel.textColor = model.isError ? .systemRed : .secondaryLabel

        needTexts = model.needTexts
        hostsRows = model.rows

        // While a number is typed the requirement rows stay as they are,
        // so the field keeps the keyboard; only the subnets are redrawn.
        guard wasHostsMode, previousNeedCount == needTexts.count else {
            tableView.reloadData()
            if wasHostsMode, needTexts.count == previousNeedCount + 1 {
                focusNeed(at: needTexts.count - 1)
            }
            return
        }
        UIView.performWithoutAnimation {
            tableView.reloadSections(IndexSet(integer: HostsSection.subnets.rawValue), with: .none)
        }
    }
}

private extension SubnetSplitView {
    func focusNeed(at index: Int) {
        let indexPath = IndexPath(row: index, section: HostsSection.needs.rawValue)
        tableView.layoutIfNeeded()
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        (tableView.cellForRow(at: indexPath) as? SubnetNeedTableViewCell)?.startEditing()
    }

    func isAddNeedRow(_ indexPath: IndexPath) -> Bool {
        return mode == .hosts
            && indexPath.section == HostsSection.needs.rawValue
            && indexPath.row == needTexts.count
    }

    func isNeedRow(_ indexPath: IndexPath) -> Bool {
        return mode == .hosts
            && indexPath.section == HostsSection.needs.rawValue
            && indexPath.row < needTexts.count
    }

    /// The subnet shown at `indexPath`, with its requirement line in the host count mode.
    func subnetRow(at indexPath: IndexPath) -> (row: SubnetSplitRowViewModel, need: String?)? {
        switch mode {
        case .equal:
            guard equalRows.indices.contains(indexPath.row) else { return nil }
            return (equalRows[indexPath.row], nil)
        case .hosts:
            guard indexPath.section == HostsSection.subnets.rawValue,
                  hostsRows.indices.contains(indexPath.row) else { return nil }
            let hostsRow = hostsRows[indexPath.row]
            return (hostsRow.subnet, hostsRow.needText)
        }
    }
}

// MARK: - Delegate

extension SubnetSplitView: UITableViewDelegate {
    /// Header text lines up with the cells, which use `cellHorizonal` insets.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section),
              let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.headerIdentifier) else {
            return nil
        }
        var content = UIListContentConfiguration.plainHeader()
        content.text = title
        content.directionalLayoutMargins.leading = UIConstants.Spacing.cellHorizonal
        content.directionalLayoutMargins.trailing = UIConstants.Spacing.cellHorizonal
        header.contentConfiguration = content
        return header
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return isAddNeedRow(indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard isAddNeedRow(indexPath) else { return }
        delegate?.didTapAddNeed()
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isNeedRow(indexPath) else { return nil }
        let delete = UIContextualAction(style: .destructive, title: UIConstants.Text.deleteAction) { [weak self] _, _, completion in
            self?.endEditing(true)
            self?.delegate?.didDeleteNeed(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        guard let row = subnetRow(at: indexPath)?.row else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let whole = UIAction(title: UIConstants.Text.copyWholeSubnet,
                                 image: UIImage(systemName: "doc.on.doc")) { _ in
                Self.copy(row.shareText)
            }
            let values = row.items.map { item -> UIAction in
                let action = UIAction(title: item.value) { _ in
                    Self.copy(item.value)
                }
                action.subtitle = item.title
                return action
            }
            let copyTitle = NSLocalizedString("copy_action", comment: "Copy context menu action")
            return UIMenu(title: copyTitle, children: [whole] + values)
        }
    }
}

private extension SubnetSplitView {
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - DataSource

extension SubnetSplitView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mode == .hosts ? HostsSection.allCases.count : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (mode, HostsSection(rawValue: section)) {
        case (.equal, _): return equalRows.count
        case (.hosts, .needs): return needTexts.count + 1
        case (.hosts, .subnets): return hostsRows.count
        case (.hosts, nil): return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (mode, HostsSection(rawValue: section)) {
        case (.hosts, .needs): return UIConstants.Text.splitNeedsHeader
        case (.hosts, .subnets): return hostsRows.isEmpty ? nil : UIConstants.Text.splitSubnetsHeader
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAddNeedRow(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.addNeedCellIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = UIConstants.Text.splitAddNeed
            content.image = UIImage(systemName: "plus.circle.fill")
            content.textProperties.color = .systemBlue
            cell.contentConfiguration = content
            return cell
        }

        if isNeedRow(indexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SubnetNeedTableViewCell.identifier,
                                                         for: indexPath) as? SubnetNeedTableViewCell else {
                return UITableViewCell()
            }
            let index = indexPath.row
            cell.configuration(number: index + 1, text: needTexts[index])
            cell.onChange = { [weak self] text in
                self?.delegate?.didChangeNeed(at: index, text: text)
            }
            return cell
        }

        guard let subnet = subnetRow(at: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: SubnetSplitTableViewCell.identifier,
                                                     for: indexPath) as? SubnetSplitTableViewCell else {
            return UITableViewCell()
        }
        cell.configuration(with: subnet.row, need: subnet.need)
        return cell
    }
}
