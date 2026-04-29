import UIKit

final class InsightEmptyCollectionViewCell: UICollectionViewCell {
    static let identifier = "InsightEmptyCollectionViewCell"

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.38)
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.28).cgColor
        iconLabel.font = .systemFont(ofSize: 28)
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .ainaTextTertiary
        titleLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        descriptionLabel.textColor = UIColor.ainaTextTertiary.withAlphaComponent(0.75)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
    }

    func configure(mode: InsightViewController.Mode) {
        iconLabel.text = mode == .weekly ? "📋" : "📷"
        titleLabel.text = mode == .weekly ? "No weekly input" : "No scan available"
        descriptionLabel.text = mode == .weekly
            ? "Weekly check-in is only available on check-in days"
            : "There is no scan available at this date."
    }
}
