import UIKit

final class ProgressCardCollectionViewCell: UICollectionViewCell {

    static let identifier = "ProgressCardCollectionViewCell"

    // MARK: - UI

    private let container = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressLabel = UILabel()

    private let gradient = CAGradientLayer()
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {

        contentView.backgroundColor = .clear

        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.75).cgColor
        
        container.clipsToBounds = true

        // Shadow (premium feel)
        container.layer.shadowColor = UIColor.systemPink.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 12
        container.layer.shadowOffset = CGSize(width: 0, height: 6)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        ])

        // Gradient
        gradient.colors = [
            UIColor.systemPink.withAlphaComponent(0.08).cgColor,  // 👈 lighter
            UIColor.systemPink.withAlphaComponent(0.02).cgColor   // 👈 almost fade out
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 24
        container.layer.insertSublayer(gradient, at: 0)

        // Track Layer
        trackLayer.strokeColor =  UIColor.ainaCoralPink.withAlphaComponent(0.75).cgColor
        trackLayer.lineWidth = 4
        trackLayer.fillColor = UIColor.clear.cgColor
        container.layer.addSublayer(trackLayer)

        // Progress Layer
        progressLayer.strokeColor = UIColor.systemPink
            .withAlphaComponent(0.3)
            .cgColor
        progressLayer.lineWidth = 5
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        container.layer.addSublayer(progressLayer)

        // Progress Label
        progressLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressLabel)

        // Title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        // Layout
        NSLayoutConstraint.activate([

            // Progress Label (center of circle)
            progressLabel.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: 16 + 22),
            progressLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            // Title
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 80),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),

            // Subtitle
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        gradient.frame = container.bounds

        // Circle path
        let radius: CGFloat = 22

        let center = CGPoint(
            x: radius + 16, // 👈 THIS FIXES LEFT PADDING
            y: container.bounds.height / 2
        )
        

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 2 * .pi,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    // MARK: - Configure

    func configure(completed: Int, total: Int) {

        let safeTotal = max(total, 1)
        let progress = CGFloat(completed) / CGFloat(safeTotal)

        progressLabel.text = "\(completed)/\(total)"

        // Animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.presentation()?.strokeEnd ?? 0
        animation.toValue = progress
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        progressLayer.strokeEnd = progress
        progressLayer.add(animation, forKey: "progress")

        // Text update
        if completed >= total && total != 0 {
            titleLabel.text = "All done 🎉"
            subtitleLabel.text = "Great job!"
        } else {
            let remaining = total - completed

            switch remaining {

            case 0:
                titleLabel.text = "All done 🎉"
                subtitleLabel.text = "Your skin thanks you ✨"

            case 1:
                titleLabel.text = "One more step!"
                subtitleLabel.text = "You’re so close 🔥"

            case 2:
                titleLabel.text = "Two more steps!"
                subtitleLabel.text = "Almost there, keep going 💪"

            case 3:
                titleLabel.text = "Three more steps!"
                subtitleLabel.text = "You’re halfway glowing ✨"

            case 4:
                titleLabel.text = "Four more steps!"
                subtitleLabel.text = "Consistency is key 👏"

            case 5:
                titleLabel.text = "Five steps to go!"
                subtitleLabel.text = "Let’s build that glow routine 🌿"

            default:
                titleLabel.text = "\(remaining) steps left"
                subtitleLabel.text = "Stay consistent 💪"
            }
        }
    }
}
