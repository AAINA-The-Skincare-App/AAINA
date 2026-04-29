import UIKit

final class InsightWeeklyInputCollectionViewCell: UICollectionViewCell {
    static let identifier = "InsightWeeklyInputCollectionViewCell"

    @IBOutlet private weak var containerView: UIView!

    private let headerView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateRangeLabel = UILabel()
    private let routineTitleLabel = UILabel()
    private let routineCard = UIView()
    private let skinTitleLabel = UILabel()
    private let skinCard = UIView()
    private let lifestyleTitleLabel = UILabel()
    private let lifestyleCard = UIStackView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func configure(entry: InsightEntry) {
        guard let weekly = entry.weeklyInputData else { return }
        titleLabel.text = weekly.insightTitle ?? "This Week's Insights"
        dateRangeLabel.text = weekRange(for: entry.dateValue)
        configureRoutineCard(entry: entry)
        configureSkinCard(weekly: weekly)
        configureLifestyleCard(weekly.lifestyleFactors)
    }

    private func setupUI() {
        containerView.backgroundColor = .clear

        [headerView, routineTitleLabel, routineCard, skinTitleLabel, skinCard, lifestyleTitleLabel, lifestyleCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        headerView.backgroundColor = UIColor.ainaLightBlush.withAlphaComponent(0.48)
        headerView.layer.cornerRadius = 16
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.35).cgColor

        [iconLabel, titleLabel, dateRangeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }

        iconLabel.text = "🗓"
        iconLabel.font = .systemFont(ofSize: 25)

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .ainaDustyRose

        dateRangeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        dateRangeLabel.textColor = UIColor.ainaDustyRose.withAlphaComponent(0.75)

        [routineTitleLabel, skinTitleLabel, lifestyleTitleLabel].forEach {
            $0.font = .systemFont(ofSize: 17, weight: .bold)
            $0.textColor = .ainaDustyRose
        }
        routineTitleLabel.text = "WHAT CHANGED"
        skinTitleLabel.text = "HOW WEEKLY INPUT HELPED"
        lifestyleTitleLabel.text = "WEEKLY SIGNALS"

        [routineCard, skinCard].forEach { card in
            card.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.22).cgColor
        }

        lifestyleCard.axis = .vertical
        lifestyleCard.spacing = 0
        lifestyleCard.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        lifestyleCard.layer.cornerRadius = 16
        lifestyleCard.layer.borderWidth = 1
        lifestyleCard.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.22).cgColor
        lifestyleCard.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        lifestyleCard.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 86),

            iconLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 48),
            iconLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -18),

            dateRangeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateRangeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

            routineTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 30),
            routineTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            routineCard.topAnchor.constraint(equalTo: routineTitleLabel.bottomAnchor, constant: 14),
            routineCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            routineCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            skinTitleLabel.topAnchor.constraint(equalTo: routineCard.bottomAnchor, constant: 28),
            skinTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            skinCard.topAnchor.constraint(equalTo: skinTitleLabel.bottomAnchor, constant: 14),
            skinCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            skinCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lifestyleTitleLabel.topAnchor.constraint(equalTo: skinCard.bottomAnchor, constant: 28),
            lifestyleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            lifestyleCard.topAnchor.constraint(equalTo: lifestyleTitleLabel.bottomAnchor, constant: 14),
            lifestyleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lifestyleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lifestyleCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func configureRoutineCard(entry: InsightEntry) {
        routineCard.subviews.forEach { $0.removeFromSuperview() }
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        routineCard.addSubview(stack)

        if let summary = entry.analysisReport?.summary {
            stack.addArrangedSubview(makeSummaryLabel(summary))
        }

        let comparisons = entry.analysisReport?.comparativeInsights ?? []
        if comparisons.isEmpty {
            stack.addArrangedSubview(makeInsightRow(title: "Weekly check-in saved", message: "Your weekly input has been added for this week.", changeType: .neutral))
        } else {
            comparisons.prefix(3).forEach { insight in
                stack.addArrangedSubview(makeInsightRow(
                    title: insight.location.map { "\(insight.attribute) • \($0)" } ?? insight.attribute,
                    message: insight.message,
                    changeType: insight.changeType
                ))
            }
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: routineCard.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: routineCard.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: routineCard.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: routineCard.bottomAnchor, constant: -16)
        ])
    }

    private func configureSkinCard(weekly: InsightWeeklyInput) {
        skinCard.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = weekly.correlationLogic ?? weekly.notes ?? "Your weekly check-in adds context from sleep, stress, hydration, and skin feel so scan changes can be compared more accurately."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .ainaTextSecondary
        label.numberOfLines = 0
        skinCard.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: skinCard.topAnchor, constant: 18),
            label.leadingAnchor.constraint(equalTo: skinCard.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: skinCard.trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: skinCard.bottomAnchor, constant: -18)
        ])
    }

    private func configureLifestyleCard(_ factors: InsightLifestyleFactors) {
        lifestyleCard.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let sleepQuality = factors.sleepQuality {
            lifestyleCard.addArrangedSubview(makeRow(title: "Sleep quality", value: sleepQuality >= 4 ? "Good" : "Needs care"))
            lifestyleCard.addArrangedSubview(makeSeparator())
        }
        if let stressLevel = factors.stressLevel {
            lifestyleCard.addArrangedSubview(makeRow(title: "Stress level", value: stressLevel > 0.65 ? "High" : "Low"))
            lifestyleCard.addArrangedSubview(makeSeparator())
        }
        if let water = factors.waterIntakeAvg {
            lifestyleCard.addArrangedSubview(makeRow(title: "Water intake", value: "\(water) glasses/day avg"))
        }
        if lifestyleCard.arrangedSubviews.isEmpty {
            lifestyleCard.addArrangedSubview(makeRow(title: "Weekly input", value: "Saved"))
        }
    }

    private func makeSummaryLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .ainaTextPrimary
        label.numberOfLines = 0
        return label
    }

    private func makeInsightRow(title: String, message: String, changeType: InsightChangeType) -> UIView {
        let row = UIView()
        let marker = UIView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()

        [marker, titleLabel, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        marker.backgroundColor = insightColor(for: changeType)
        marker.layer.cornerRadius = 5

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .ainaTextPrimary
        titleLabel.numberOfLines = 0

        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .ainaTextSecondary
        messageLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 58),
            marker.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            marker.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),
            marker.widthAnchor.constraint(equalToConstant: 10),
            marker.heightAnchor.constraint(equalToConstant: 10),
            titleLabel.topAnchor.constraint(equalTo: row.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: marker.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    private func insightColor(for changeType: InsightChangeType) -> UIColor {
        switch changeType {
        case .positive: return .ainaSageGreen
        case .negative: return .ainaSoftRed
        case .neutral: return .systemBlue
        }
    }

    private func makeRoutineBlock(title: String, days: [String], faded: [String]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.backgroundColor = UIColor.white.withAlphaComponent(0.62)
        stack.layer.cornerRadius = 12
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .ainaTextSecondary
        stack.addArrangedSubview(label)

        let daysStack = UIStackView()
        daysStack.spacing = 7
        (days + faded).forEach { day in
            let pill = UILabel()
            pill.text = day
            pill.textAlignment = .center
            pill.font = .systemFont(ofSize: 13, weight: .bold)
            pill.textColor = days.contains(day) ? .white : .ainaTextTertiary
            pill.backgroundColor = days.contains(day) ? .ainaDustyRose : UIColor.ainaTextTertiary.withAlphaComponent(0.16)
            pill.layer.cornerRadius = 17
            pill.clipsToBounds = true
            pill.widthAnchor.constraint(equalToConstant: 34).isActive = true
            pill.heightAnchor.constraint(equalToConstant: 34).isActive = true
            daysStack.addArrangedSubview(pill)
        }
        stack.addArrangedSubview(daysStack)
        return stack
    }

    private func makeChip(_ text: String, positive: Bool) -> UILabel {
        let label = PaddingLabel()
        label.padding = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = positive ? UIColor(red: 0.02, green: 0.44, blue: 0.33, alpha: 1) : UIColor.ainaDustyRose
        label.backgroundColor = positive ? UIColor.ainaSageGreen.withAlphaComponent(0.12) : UIColor.ainaLightBlush.withAlphaComponent(0.48)
        label.layer.cornerRadius = 18
        label.layer.borderWidth = 1
        label.layer.borderColor = positive ? UIColor.ainaSageGreen.withAlphaComponent(0.35).cgColor : UIColor.ainaCoralPink.withAlphaComponent(0.35).cgColor
        label.clipsToBounds = true
        return label
    }

    private func makeRow(title: String, value: String) -> UIView {
        let row = UIView()
        let titleLabel = UILabel()
        let valueLabel = UILabel()
        [titleLabel, valueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .ainaTextSecondary
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .ainaTextPrimary
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.16)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    private func weekRange(for date: Date?) -> String {
        guard let date else { return "" }
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
