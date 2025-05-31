import UIKit

final class NavigationTitleView: UIView {

    // MARK: - Outlets

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: UIConstants.Image.ipIcon)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = UIConstants.Text.title
        label.applyScaledFont(size: UIConstants.FontSize.title,
                              weight: .semibold,
                              textStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = UIConstants.Spacing.stackViewSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

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

private extension NavigationTitleView {
    func setupView() {
        backgroundColor = .white
    }

    func setupHierarchy() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        addSubview(stackView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: UIConstants.Spacing.screenHorizontal),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -UIConstants.Spacing.screenHorizontal),
            imageView.widthAnchor.constraint(equalToConstant: UIConstants.Size.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: UIConstants.Size.imageSize)
        ])
    }
}
