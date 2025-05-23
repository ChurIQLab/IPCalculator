import UIKit

final class MainView: UIView {

    // MARK: - Initial

    init() {
        super.init(frame: .zero)
        setupView()
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension MainView {
    func setupView() {
        backgroundColor = .systemBlue
    }

    func setupHierarchy() {
        print("Setup Hierarchy MAIN UI")
    }

    func setupLayout() {
        print("Setup Layout MAIN UI")
    }
}

// MARK: - Public func

extension MainView {
    func configuration(with model: MainViewModel) {
        print("Configuration MAIN UI")
    }
}
