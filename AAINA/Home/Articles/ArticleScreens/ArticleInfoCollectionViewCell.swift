import UIKit

final class ArticleInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleInfoCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
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
        iconLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        iconLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        titleLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor.ainaTextSecondary
        descriptionLabel.numberOfLines = 0
    }

    func configure(item: ArticleCardItem, isWarning: Bool = false) {
        iconLabel.attributedText = iconText(for: item.icon, isWarning: isWarning)
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }

    private func iconText(for key: String?, isWarning: Bool) -> NSAttributedString {
        let symbolName = key ?? (isWarning ? "exclamationmark.triangle.fill" : "sparkles")
        if let image = UIImage(systemName: symbolName) {
            let color: UIColor = isWarning ? .ainaSoftRed : (symbolName.contains("moon") ? .systemPurple : .systemBlue)
            let attachment = NSTextAttachment()
            attachment.image = image.withTintColor(color, renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -5, width: 26, height: 26)
            return NSAttributedString(attachment: attachment)
        }
        return NSAttributedString(string: isWarning ? "⚠" : "✦")
    }
}
