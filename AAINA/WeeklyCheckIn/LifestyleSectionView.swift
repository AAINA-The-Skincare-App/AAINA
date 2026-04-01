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
    @IBOutlet private weak var waterMinusButton: UIButton!
    @IBOutlet private weak var waterPlusButton: UIButton!

    // MARK: - Callbacks
    var onSleepChanged: ((Int) -> Void)?
    var onStressChanged: ((Float) -> Void)?
    var onWaterChanged: ((Int) -> Void)?

    // MARK: - State
    private let sleepEmojis = ["😫", "😕", "😐", "🙂", "😊"]
    private let waterGoal = 8

    private var sleepButtons = [UIButton]()
    private var waterSegments = [UIView]()

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
        for card in [sleepCard, stressCard, waterCard] {
            card?.backgroundColor = .ainaGlassElevated
            card?.layer.cornerRadius = 16
            card?.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
            card?.layer.shadowOpacity = 0.08
            card?.layer.shadowOffset = CGSize(width: 0, height: 2)
            card?.layer.shadowRadius = 8
        }
        buildSleepButtons()
        buildWaterSegments()
        configureSlider()
        waterMinusButton.addTarget(self, action: #selector(waterMinus), for: .touchUpInside)
        waterPlusButton.addTarget(self, action: #selector(waterPlus), for: .touchUpInside)
    }

    // MARK: - Build
    private func buildSleepButtons() {
        sleepEmojiStack.axis = .horizontal
        sleepEmojiStack.spacing = 8
        sleepEmojiStack.distribution = .fillEqually

        for (i, emoji) in sleepEmojis.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(emoji, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 22)
            btn.tag = 300 + i
            btn.layer.cornerRadius = 12
            btn.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.2)
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.addTarget(self, action: #selector(sleepTapped(_:)), for: .touchUpInside)
            sleepButtons.append(btn)
            sleepEmojiStack.addArrangedSubview(btn)
        }
    }

    private func buildWaterSegments() {
        waterSegmentStack.axis = .horizontal
        waterSegmentStack.spacing = 4
        waterSegmentStack.distribution = .fillEqually

        for _ in 0..<waterGoal {
            let seg = UIView()
            seg.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.25)
            seg.layer.cornerRadius = 3
            seg.heightAnchor.constraint(equalToConstant: 8).isActive = true
            waterSegments.append(seg)
            waterSegmentStack.addArrangedSubview(seg)
        }

        waterCountLabel.text = "0 glasses/day avg"
        waterCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        waterCountLabel.textColor = .ainaDustyRose
    }

    private func configureSlider() {
        stressSlider.minimumValue = 0
        stressSlider.maximumValue = 1
        stressSlider.value = 0.5
        stressSlider.minimumTrackTintColor = .ainaDustyRose
        stressSlider.maximumTrackTintColor = UIColor.ainaTextTertiary.withAlphaComponent(0.4)
        stressSlider.thumbTintColor = .white
        stressSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }

    // MARK: - Actions
    @objc private func sleepTapped(_ sender: UIButton) {
        selectedSleep = sender.tag - 300
        for (i, btn) in sleepButtons.enumerated() {
            let isSelected = i == selectedSleep
            btn.backgroundColor = isSelected ? UIColor.ainaTintedGlassLight : UIColor.ainaTextTertiary.withAlphaComponent(0.2)
            btn.layer.borderWidth = isSelected ? 1.5 : 0
            btn.layer.borderColor = isSelected ? UIColor.ainaDustyRose.cgColor : UIColor.clear.cgColor
        }
        onSleepChanged?(selectedSleep)
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        stressLevel = sender.value
        onStressChanged?(stressLevel)
    }

    @IBAction private func waterPlus() {
        if waterGlasses < waterGoal { waterGlasses += 1 }
    }

    @IBAction private func waterMinus() {
        if waterGlasses > 0 { waterGlasses -= 1 }
    }

    private func refreshWater() {
        for (i, seg) in waterSegments.enumerated() {
            seg.backgroundColor = i < waterGlasses
                ? UIColor.ainaSageGreen
                : UIColor.ainaTextTertiary.withAlphaComponent(0.25)
        }
        waterCountLabel.text = "\(waterGlasses) glasses/day avg"
        onWaterChanged?(waterGlasses)
    }
}
