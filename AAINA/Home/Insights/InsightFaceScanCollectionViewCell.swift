import UIKit

final class InsightFaceScanCollectionViewCell: UICollectionViewCell {
    static let identifier = "InsightFaceScanCollectionViewCell"

    @IBOutlet private weak var containerView: UIView!

    private let imageView = UIImageView()
    private let tagLabel = UILabel()
    private let dateLabel = UILabel()
    private let detectedTitleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let chipsStackView = UIStackView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        chipsStackView.arrangedSubviews.forEach {
            chipsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        imageView.image = nil
    }

    func configure(entry: InsightEntry, image: UIImage?) {
        imageView.image = image ?? UIImage(named: "FemaleFace")
        tagLabel.text = entry.hasWeeklyInput ? "Weekly scan" : "Face scan"
        dateLabel.text = shortDate(entry.dateValue)
        summaryLabel.text = entry.analysisReport?.summary ?? "Face scan comparison"

        let comparisons = entry.analysisReport?.comparativeInsights ?? []
        if comparisons.isEmpty {
            let features = entry.aiDetection.detectedFeatures
            if features.isEmpty {
                chipsStackView.addArrangedSubview(makeComparisonCard(title: "No concerns detected", message: "No visible changes were detected in this scan.", changeType: .positive))
            } else {
                features.prefix(3).forEach { feature in
                    chipsStackView.addArrangedSubview(makeComparisonCard(
                        title: feature.issue,
                        message: "\(feature.severity.capitalized) signs around \(feature.location.lowercased()).",
                        changeType: severityLooksPositive(feature.severity) ? .positive : .neutral
                    ))
                }
            }
        } else {
            comparisons.prefix(3).forEach { insight in
                let location = insight.location.map { " • \($0)" } ?? ""
                chipsStackView.addArrangedSubview(makeComparisonCard(
                    title: "\(insight.attribute)\(location)",
                    message: insight.message,
                    changeType: insight.changeType
                ))
            }
        }
    }

    private func setupUI() {
        containerView.backgroundColor = UIColor.ainaLightBlush.withAlphaComponent(0.28)
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.22).cgColor
        containerView.clipsToBounds = true

        [imageView, tagLabel, dateLabel, detectedTitleLabel, summaryLabel, chipsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.68

        tagLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        tagLabel.textColor = .ainaDustyRose
        tagLabel.backgroundColor = UIColor.ainaLightBlush.withAlphaComponent(0.85)
        tagLabel.layer.cornerRadius = 15
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center

        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = .ainaTextSecondary
        dateLabel.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        dateLabel.layer.cornerRadius = 15
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center

        detectedTitleLabel.text = "SCAN COMPARISON"
        detectedTitleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        detectedTitleLabel.textColor = .ainaDustyRose

        summaryLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        summaryLabel.textColor = .ainaTextSecondary
        summaryLabel.numberOfLines = 0

        chipsStackView.axis = .vertical
        chipsStackView.alignment = .fill
        chipsStackView.distribution = .fill
        chipsStackView.spacing = 10

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 235),

            tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tagLabel.heightAnchor.constraint(equalToConstant: 30),
            tagLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 116),

            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            dateLabel.heightAnchor.constraint(equalToConstant: 30),
            dateLabel.widthAnchor.constraint(equalToConstant: 92),

            detectedTitleLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 28),
            detectedTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            detectedTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            summaryLabel.topAnchor.constraint(equalTo: detectedTitleLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            chipsStackView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 14),
            chipsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            chipsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            chipsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    private func makeComparisonCard(title: String, message: String, changeType: InsightChangeType) -> UIView {
        let card = UIView()
        let iconLabel = UILabel()
        let titleLabel = UILabel()
        let messageLabel = UILabel()

        [iconLabel, titleLabel, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        card.backgroundColor = UIColor.white.withAlphaComponent(0.62)
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = color(for: changeType).withAlphaComponent(0.28).cgColor

        iconLabel.text = icon(for: changeType)
        iconLabel.font = .systemFont(ofSize: 18, weight: .bold)
        iconLabel.textAlignment = .center
        iconLabel.textColor = color(for: changeType)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .ainaTextPrimary
        titleLabel.numberOfLines = 0

        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .ainaTextSecondary
        messageLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 78),

            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconLabel.widthAnchor.constraint(equalToConstant: 26),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    private func icon(for changeType: InsightChangeType) -> String {
        switch changeType {
        case .positive: return "↑"
        case .negative: return "!"
        case .neutral: return "i"
        }
    }

    private func color(for changeType: InsightChangeType) -> UIColor {
        switch changeType {
        case .positive: return .ainaSageGreen
        case .negative: return .ainaSoftRed
        case .neutral: return .systemBlue
        }
    }

    private func shortDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func severityLooksPositive(_ severity: String) -> Bool {
        ["low", "mild", "fading", "clear"].contains(severity.lowercased())
    }
}
