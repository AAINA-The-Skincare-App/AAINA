//
//  LifestyleSectionView.swift
//  AAINA
//

import UIKit

final class LifestyleSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var sleepCard: UIView!
    @IBOutlet private weak var stressCard: UIView!
    @IBOutlet private weak var waterCard: UIView!
    @IBOutlet private weak var sleepEmojiStack: UIStackView!
    @IBOutlet private weak var stressSlider: UISlider!
    @IBOutlet private weak var waterCountLabel: UILabel!
    @IBOutlet private weak var waterSegmentStack: UIStackView!

    // MARK: - Callbacks
    var onSleepChanged: ((Int) -> Void)?
    var onStressChanged: ((Float) -> Void)?
    var onWaterChanged: ((Int) -> Void)?

    // MARK: - State
    private let sleepEmojis = ["😫", "😕", "😐", "🙂", "😊"]
    private let waterGoal   = 8
    private var waterGradientLayer: CAGradientLayer?

    private var sleepButtons  = [UIButton]()
    private var dropButtons   = [UIButton]()

    private(set) var selectedSleep = -1
    private(set) var stressLevel: Float = 0.5
    private(set) var waterGlasses = 0 { didSet { refreshWater() } }

    // MARK: - Factory
    static func create() -> LifestyleSectionView {
        let views = Bundle.main.loadNibNamed("LifestyleSectionView", owner: nil, options: nil)!
        return views.first as! LifestyleSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        for card in [sleepCard, stressCard] {
            card?.backgroundColor    = .ainaGlassElevated
            card?.layer.cornerRadius = 16
            card?.layer.shadowColor  = UIColor.ainaCardShadowColor.cgColor
            card?.layer.shadowOpacity = 0.08
            card?.layer.shadowOffset  = CGSize(width: 0, height: 2)
            card?.layer.shadowRadius  = 8
        }
        waterCard?.backgroundColor    = .ainaGlassElevated
        waterCard?.layer.cornerRadius = 16
        waterCard?.layer.shadowColor  = UIColor.ainaCardShadowColor.cgColor
        waterCard?.layer.shadowOpacity = 0.08
        waterCard?.layer.shadowOffset  = CGSize(width: 0, height: 2)
        waterCard?.layer.shadowRadius  = 8

        buildSleepButtons()
        buildDropButtons()
        configureSlider()
    }

    // MARK: - Sleep buttons

    private func buildSleepButtons() {
        sleepEmojiStack.axis         = .horizontal
        sleepEmojiStack.spacing      = 8
        sleepEmojiStack.distribution = .fillEqually

        for (i, emoji) in sleepEmojis.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(emoji, for: .normal)
            btn.titleLabel?.font    = .systemFont(ofSize: 22)
            btn.tag                 = 300 + i
            btn.layer.cornerRadius  = 12
            btn.backgroundColor     = UIColor.ainaTextTertiary.withAlphaComponent(0.2)
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.addTarget(self, action: #selector(sleepTapped(_:)), for: .touchUpInside)
            sleepButtons.append(btn)
            sleepEmojiStack.addArrangedSubview(btn)
        }
    }

    // MARK: - Water drop buttons (tap to select)

    private func buildDropButtons() {
        waterSegmentStack.axis         = .horizontal
        waterSegmentStack.spacing      = 4
        waterSegmentStack.distribution = .fillEqually
        waterSegmentStack.alignment    = .center

        let emptyColor = UIColor.ainaDustyRose.withAlphaComponent(0.25)

        for i in 0..<waterGoal {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: "drop.fill"), for: .normal)
            btn.tintColor   = emptyColor
            btn.tag         = i + 1
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
            btn.addTarget(self, action: #selector(dropTapped(_:)), for: .touchUpInside)
            dropButtons.append(btn)
            waterSegmentStack.addArrangedSubview(btn)
        }

        waterCountLabel.text      = "0 / \(waterGoal) glasses"
        waterCountLabel.font      = .systemFont(ofSize: 13, weight: .semibold)
        waterCountLabel.textColor = .secondaryLabel
    }

    // MARK: - Slider

    private func configureSlider() {
        stressSlider.minimumValue        = 0
        stressSlider.maximumValue        = 1
        stressSlider.value               = 0.5
        stressSlider.minimumTrackTintColor = .ainaDustyRose
        stressSlider.maximumTrackTintColor = UIColor.ainaTextTertiary.withAlphaComponent(0.4)
        stressSlider.thumbTintColor      = .white
        stressSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }

    // MARK: - Actions

    @objc private func sleepTapped(_ sender: UIButton) {
        selectedSleep = sender.tag - 300
        for (i, btn) in sleepButtons.enumerated() {
            let sel = i == selectedSleep
            btn.backgroundColor   = sel ? UIColor.ainaCoralPink.withAlphaComponent(0.75) : UIColor.ainaTextTertiary.withAlphaComponent(0.2)
            btn.layer.borderWidth = sel ? 1.5 : 0
            btn.layer.borderColor = sel ? UIColor.ainaDustyRose.cgColor : UIColor.clear.cgColor
        }
        onSleepChanged?(selectedSleep)
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        stressLevel = sender.value
        onStressChanged?(stressLevel)
    }

    // Tapping drop N sets glasses = N; tapping the same drop again clears to 0.
    @objc private func dropTapped(_ sender: UIButton) {
        waterGlasses = (waterGlasses == sender.tag) ? 0 : sender.tag
    }

    // MARK: - Water refresh

    private func refreshWater() {
        let blueColor  = UIColor(red: 0.22, green: 0.56, blue: 0.87, alpha: 1)
        let emptyColor = UIColor.ainaDustyRose.withAlphaComponent(0.25)
        for btn in dropButtons {
            UIView.animate(withDuration: 0.15) {
                btn.tintColor = btn.tag <= self.waterGlasses ? blueColor : emptyColor
            }
        }
        let pct = Int((Float(waterGlasses) / Float(waterGoal)) * 100)
        waterCountLabel.text      = "\(waterGlasses) / \(waterGoal) glasses  ·  \(pct)%"
        waterCountLabel.textColor = waterGlasses >= waterGoal ? blueColor : .secondaryLabel
        onWaterChanged?(waterGlasses)
    }

    // MARK: - Gradient (water card background)

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let waterCard else { return }
        if waterGradientLayer == nil {
            let grad = CAGradientLayer()
            grad.colors = [
                UIColor(red: 0.84, green: 0.93, blue: 0.99, alpha: 0.55).cgColor,
                UIColor(red: 0.98, green: 0.91, blue: 0.93, alpha: 0.45).cgColor
            ]
            grad.startPoint   = CGPoint(x: 0, y: 0)
            grad.endPoint     = CGPoint(x: 1, y: 1)
            grad.cornerRadius = 16
            waterCard.layer.insertSublayer(grad, at: 0)
            waterGradientLayer = grad
        }
        waterGradientLayer?.frame = waterCard.bounds
    }
}
