import UIKit

final class CalendarDateCell: UICollectionViewCell {

    private let label = UILabel()
    private let circleView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Circle View
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 17       // 🔥 half of 34 — set once here, not in layoutSubviews
        circleView.layer.cornerCurve = .circular
        circleView.layer.masksToBounds = true
        contentView.addSubview(circleView)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 34),
            circleView.heightAnchor.constraint(equalToConstant: 34)
        ])

        // Label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // layoutSubviews no longer needed for corner radius

    func configure(text: String, selected: Bool, isToday: Bool) {
        label.text = text

        if text.isEmpty {
            circleView.backgroundColor = .clear
            label.textColor = .clear
            return
        }

        if selected {
            circleView.backgroundColor = UIColor.ainaCoralPink
            label.textColor = .white

        } else if isToday {
            circleView.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.2)
            label.textColor = UIColor.ainaCoralPink

        } else {
            circleView.backgroundColor = .clear
            label.textColor = .label
        }
    }
}
