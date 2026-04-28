import UIKit

class IngredientCardView: UIView {

    let stack = UIStackView()

    // Main horizontal layout
    private let mainStack = UIStackView()

    private let titleLabel = UILabel()
    private let textLabel = UILabel()

    init(iconView: UIView? = nil) {
        super.init(frame: .zero)
        setup(iconView: iconView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(iconView: UIView?) {

        // MARK: - Card Styling
        backgroundColor = UIColor.white.withAlphaComponent(0.78)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 5)
        clipsToBounds = false

        // MARK: - Main Stack (HORIZONTAL)
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .top   //  critical (prevents text going below icon)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        // MARK: - Icon (LEFT)
        if let icon = iconView {

            // Prevent icon from stretching
            icon.setContentHuggingPriority(.required, for: .horizontal)
            icon.setContentCompressionResistancePriority(.required, for: .horizontal)

            mainStack.addArrangedSubview(icon)
        }

        // MARK: - Right Content Stack (VERTICAL)
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading   // ensures text aligns nicely
        stack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.addArrangedSubview(stack)

        // MARK: - Text Styling
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1

        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0   // allows wrapping

        // MARK: - Add Views
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(8, after: titleLabel)
        stack.addArrangedSubview(textLabel)
    }

    // MARK: - Public API

    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    func setText(_ text: String) {
        textLabel.text = text
    }
}
