import UIKit

final class ArticleBadgesCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleBadgesCollectionViewCell"

    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        stackView.axis = .horizontal
        stackView.spacing = 14
        stackView.alignment = .center
        stackView.distribution = .fill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    func configure(badges: [String]) {
        badges.forEach { stackView.addArrangedSubview(makeBadge($0)) }
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacer)
    }

    private func makeBadge(_ text: String) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.ainaTextPrimary.withAlphaComponent(0.82)
        label.backgroundColor = UIColor.ainaGlassElevated
        label.layer.cornerRadius = 14
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
}
