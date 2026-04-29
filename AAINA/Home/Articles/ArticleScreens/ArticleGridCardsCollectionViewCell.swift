import UIKit

final class ArticleGridCardsCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleGridCardsCollectionViewCell"

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 16
    }

    func configure(items: [ArticleCardItem]) {
        items.forEach { stackView.addArrangedSubview(makeCard(for: $0)) }
    }

    private func makeCard(for item: ArticleCardItem) -> UIView {
        let card = UIView()
        let iconLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()

        card.translatesAutoresizingMaskIntoConstraints = false
        [iconLabel, titleLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        card.backgroundColor = UIColor.ainaGlassElevated
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
        card.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowRadius = 16
        card.layer.shadowOffset = CGSize(width: 0, height: 8)

        iconLabel.attributedText = iconText(for: item.icon)
        iconLabel.textAlignment = .center
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        titleLabel.numberOfLines = 0
        descriptionLabel.text = item.description
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor.ainaTextSecondary
        descriptionLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 230),

            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 34),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -18)
        ])

        return card
    }

    private func iconText(for key: String?) -> NSAttributedString {
        let symbolName = key ?? "checkmark.circle"
        if let image = UIImage(systemName: symbolName) {
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(iconColor(for: symbolName), renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -5, width: 26, height: 26)
            return NSAttributedString(attachment: attachment)
        }
        return NSAttributedString(string: "✓", attributes: [.foregroundColor: UIColor.ainaSageGreen])
    }

    private func iconColor(for key: String) -> UIColor {
        switch key {
        case "timer", "drop.fill", "drop.circle.fill", "drop.triangle.fill": return UIColor.systemBlue
        case "arrow.up.circle.fill", "checkmark.shield.fill", "shield.lefthalf.filled": return UIColor.ainaSageGreen
        case "exclamationmark.triangle.fill": return UIColor.ainaSoftRed
        case "moon.stars.fill": return UIColor.systemPurple
        case "sun.max.fill", "cloud.sun.fill": return UIColor.systemOrange
        default: return UIColor.ainaDustyRose
        }
    }
}
