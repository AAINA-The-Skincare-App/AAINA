import UIKit

final class ArticleIntroCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleIntroCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var pillsStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        pillsStackView.arrangedSubviews.forEach {
            pillsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = UIColor.ainaGlassElevated
        containerView.layer.cornerRadius = 28
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.10
        containerView.layer.shadowRadius = 18
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)

        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = UIColor.ainaTextSecondary
        bodyLabel.numberOfLines = 0

        pillsStackView.axis = .horizontal
        pillsStackView.alignment = .center
        pillsStackView.distribution = .equalSpacing
        pillsStackView.spacing = 8
    }

    func configure(section: ArticleSection) {
        bodyLabel.text = section.content
        (section.pills ?? []).enumerated().forEach { index, pill in
            if index > 0 {
                let arrow = UILabel()
                arrow.text = "→"
                arrow.font = .systemFont(ofSize: 20, weight: .medium)
                arrow.textColor = UIColor.ainaTextSecondary
                pillsStackView.addArrangedSubview(arrow)
            }

            let label = UILabel()
            label.text = pill
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = UIColor.ainaTextPrimary.withAlphaComponent(0.72)
            pillsStackView.addArrangedSubview(label)
        }
    }
}
