import UIKit

final class ArticleTimelineCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleTimelineCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
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
        stackView.axis = .vertical
        stackView.spacing = 20
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    func configure(steps: [ArticleTimelineStep]) {
        steps.forEach { stackView.addArrangedSubview(makeRow($0)) }
    }

    private func makeRow(_ step: ArticleTimelineStep) -> UIView {
        let row = UIView()
        let dot = UIView()
        let label = PaddingLabel()
        let body = UILabel()

        [dot, label, body].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        dot.backgroundColor = color(for: step.color)
        dot.layer.cornerRadius = 8
        label.text = step.label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.ainaTextPrimary.withAlphaComponent(0.72)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.84)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.padding = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        label.numberOfLines = 0
        body.text = step.text
        body.font = .systemFont(ofSize: 15, weight: .regular)
        body.textColor = UIColor.ainaTextSecondary
        body.numberOfLines = 0

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.topAnchor.constraint(equalTo: row.topAnchor, constant: 4),
            dot.widthAnchor.constraint(equalToConstant: 16),
            dot.heightAnchor.constraint(equalToConstant: 16),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 18),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),

            body.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            body.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            body.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    private func color(for key: String) -> UIColor {
        switch key {
        case "green": return UIColor.systemGreen.withAlphaComponent(0.35)
        case "purple": return UIColor.systemPurple.withAlphaComponent(0.45)
        case "orange": return UIColor.systemOrange.withAlphaComponent(0.35)
        case "red": return UIColor.systemRed.withAlphaComponent(0.35)
        case "blue": return UIColor.systemBlue.withAlphaComponent(0.35)
        default: return UIColor.ainaCoralPink.withAlphaComponent(0.45)
        }
    }
}
