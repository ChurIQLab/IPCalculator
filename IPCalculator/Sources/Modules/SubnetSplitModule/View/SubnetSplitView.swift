import UIKit

protocol SubnetSplitViewDelegate: AnyObject {
    func didSelectPrefix(at index: Int)
}

final class SubnetSplitView: UIView {

    // MARK: - Properties

    weak var delegate: SubnetSplitViewDelegate?

    private var rows: [SubnetSplitRowViewModel] = []

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

    private let prefixLabel: UILabel = {
        let label = UILabel()
        label.text = UIConstants.Text.splitPrefixLabel
        label.textColor = .label
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .medium,
                              textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.applyScaledFont(size: UIConstants.FontSize.small,
                              weight: .regular,
                              textStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)

        table.register(SubnetSplitTableViewCell.self,
                       forCellReuseIdentifier: SubnetSplitTableViewCell.identifier)

        table.dataSource = self
        table.delegate = self

        table.allowsSelection = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UIConstants.Size.subnetCellEstimatedHeight

        table.layer.cornerRadius = UIConstants.CornerRadius.normal
        table.layer.borderWidth = UIConstants.Size.borderWidth
        table.layer.borderColor = UIColor.systemGray5.cgColor

        table.separatorInset = .zero
        table.separatorColor = .systemGray5

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

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
        addSubview(prefixLabel)
        addSubview(prefixButton)
        addSubview(summaryLabel)
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
            prefixLabel.topAnchor.constraint(equalTo: networkLabel.bottomAnchor,
                                             constant: UIConstants.Spacing.screenVertial),
            prefixLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: UIConstants.Spacing.screenHorizontal),
            prefixButton.topAnchor.constraint(equalTo: prefixLabel.bottomAnchor,
                                              constant: UIConstants.Spacing.labelToTextField),
            prefixButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                  constant: UIConstants.Spacing.screenHorizontal),
            prefixButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                   constant: -UIConstants.Spacing.screenHorizontal),
            prefixButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.Size.textFieldHeight),
            summaryLabel.topAnchor.constraint(equalTo: prefixButton.bottomAnchor,
                                              constant: UIConstants.Spacing.labelToTextField),
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                  constant: UIConstants.Spacing.screenHorizontal),
            summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                   constant: -UIConstants.Spacing.screenHorizontal),
            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor,
                                           constant: UIConstants.Spacing.screenVertial),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: UIConstants.Spacing.screenHorizontal),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -UIConstants.Spacing.screenHorizontal),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
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
}

// MARK: - Public func

extension SubnetSplitView {
    func configuration(with model: SubnetSplitViewModel) {
        networkLabel.text = model.networkText
        summaryLabel.text = model.summaryText

        if model.prefixOptions.indices.contains(model.selectedPrefixIndex) {
            prefixButton.configuration?.title = model.prefixOptions[model.selectedPrefixIndex]
        }
        prefixButton.menu = makePrefixMenu(options: model.prefixOptions, selectedIndex: model.selectedPrefixIndex)

        rows = model.rows
        tableView.reloadData()
        if !rows.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - Delegate

extension SubnetSplitView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        guard rows.indices.contains(indexPath.row) else { return nil }
        let row = rows[indexPath.row]

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubnetSplitTableViewCell.identifier,
                                                     for: indexPath) as? SubnetSplitTableViewCell else {
            return UITableViewCell()
        }
        cell.configuration(with: rows[indexPath.row])
        return cell
    }
}
