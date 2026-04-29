import UIKit

final class ArticleGridCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleGridCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = UIColor.ainaGlassElevated
        containerView.layer.cornerRadius = 24
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.10
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)

        iconLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        iconLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        titleLabel.numberOfLines = 2
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor.ainaTextSecondary
        descriptionLabel.numberOfLines = 0
    }

    func configure(item: ArticleCardItem) {
        iconLabel.attributedText = iconText(for: item.icon)
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }

    private func iconText(for key: String?) -> NSAttributedString {
        let symbolName = key ?? "checkmark.circle"
        if let image = UIImage(systemName: symbolName) {
            let color = iconColor(for: symbolName)
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(color, renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -5, width: 25, height: 25)
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
