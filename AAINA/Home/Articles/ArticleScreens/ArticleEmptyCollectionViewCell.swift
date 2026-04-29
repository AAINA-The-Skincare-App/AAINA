import UIKit

final class ArticleEmptyCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleEmptyCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        containerView.layer.cornerRadius = 28
        containerView.layer.cornerCurve = .continuous
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor.ainaTextSecondary
        descriptionLabel.numberOfLines = 0
    }

    func configure() {
        titleLabel.text = "Article coming soon"
        descriptionLabel.text = "Content for this article is not in Articles.json yet. Once the JSON is updated, this screen will fill automatically."
    }
}
