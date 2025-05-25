import UIKit

final class MainTableView: UIView {

    // MARK: - Properties

    private var rows: [MainTableViewModel] = []

    // MARK: - Outlets

    private(set) lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)

        table.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        table.register(MainTableViewHeader.self, forHeaderFooterViewReuseIdentifier: MainTableViewHeader.identifier)

        table.dataSource = self
        table.delegate = self

        table.allowsSelection = false
        table.isScrollEnabled = false

        table.layer.cornerRadius = 8
        table.layer.borderWidth = 1
        table.layer.borderColor = UIColor.systemGray5.cgColor

        table.separatorInset = .zero
        table.separatorColor = .systemGray5

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension MainTableView {
    func setupHierarchy() {
        addSubview(tableView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Public methods

extension MainTableView {
    func configuration(with rows: [MainTableViewModel]) {
        self.rows = rows
        tableView.reloadData()
    }
}

// MARK: - Delegate

extension MainTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: MainTableViewHeader.identifier
            ) as? MainTableViewHeader else { return nil }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.bounds.height / CGFloat(rows.count + 1)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(rows.count + 1)
    }
}

// MARK: - DataSource

extension MainTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier,
                                                     for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        let row = rows[indexPath.row]
        cell.configuration(with: row)
        return cell
    }
}
