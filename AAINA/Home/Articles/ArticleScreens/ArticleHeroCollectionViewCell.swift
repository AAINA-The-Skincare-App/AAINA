import UIKit

final class ArticleHeroCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleHeroCollectionViewCell"

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var metaContainerView: UIView!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 4
        articleImageView.layer.cornerCurve = .continuous

        metaContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.76)
        metaContainerView.layer.cornerRadius = 14
        metaContainerView.layer.cornerCurve = .continuous
        metaContainerView.layer.borderWidth = 1
        metaContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor

        metaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        metaLabel.textColor = .ainaDustyRose
    }

    func configure(imageName: String, readTime: String) {
        articleImageView.image = UIImage(named: imageName)
        metaLabel.attributedText = makeMetaText(readTime)
    }

    private func makeMetaText(_ meta: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if let image = UIImage(systemName: "clock")?.withTintColor(.ainaDustyRose, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: " "))
        }
        result.append(NSAttributedString(string: meta))
        return result
    }
}
