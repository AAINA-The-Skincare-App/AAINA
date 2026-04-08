//
//  RoutineConsistencySectionView.swift
//  AAINA
//

import UIKit

final class RoutineConsistencySectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var morningCard: UIView!
    @IBOutlet private weak var eveningCard: UIView!
    @IBOutlet private weak var morningDayStack: UIStackView!
    @IBOutlet private weak var eveningDayStack: UIStackView!
    @IBOutlet private weak var morningCountLabel: UILabel!
    @IBOutlet private weak var eveningCountLabel: UILabel!

    // MARK: - Callbacks
    var onMorningDaysChanged: ((Set<Int>) -> Void)?
    var onEveningDaysChanged: ((Set<Int>) -> Void)?

    // MARK: - State
    private(set) var morningDays = Set<Int>()
    private(set) var eveningDays = Set<Int>()

    private var morningDayButtons = [UIButton]()
    private var eveningDayButtons = [UIButton]()

    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]

    // MARK: - Factory
    static func create() -> RoutineConsistencySectionView {
        let views = Bundle.main.loadNibNamed("RoutineConsistencySectionView", owner: nil, options: nil)!
        return views.first as! RoutineConsistencySectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleCard(morningCard)
        styleCard(eveningCard)
        buildDayButtons()
    }

    private func styleCard(_ card: UIView) {
        card.backgroundColor = .ainaGlassElevated
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
    }

    // MARK: - Build
    private func buildDayButtons() {
        morningDayStack.axis = .horizontal
        morningDayStack.spacing = 6
        morningDayStack.distribution = .fillEqually

        eveningDayStack.axis = .horizontal
        eveningDayStack.spacing = 6
        eveningDayStack.distribution = .fillEqually

        for (i, day) in weekDays.enumerated() {
            let morningBtn = makeDayButton(title: day, tag: 1000 + i)
            morningBtn.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
            morningDayButtons.append(morningBtn)
            morningDayStack.addArrangedSubview(morningBtn)
            morningBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true

            let eveningBtn = makeDayButton(title: day, tag: 2000 + i)
            eveningBtn.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
            eveningDayButtons.append(eveningBtn)
            eveningDayStack.addArrangedSubview(eveningBtn)
            eveningBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }

        morningCountLabel.text = "0/7 days"
        morningCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        morningCountLabel.textColor = .ainaDustyRose

        eveningCountLabel.text = "0/7 days"
        eveningCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        eveningCountLabel.textColor = .ainaDustyRose
    }

    private func makeDayButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.tag = tag
        btn.layer.cornerRadius = 18
        btn.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.25)
        btn.setTitleColor(.ainaTextSecondary, for: .normal)
        return btn
    }

    // MARK: - Actions
    @objc private func dayTapped(_ sender: UIButton) {
        let tag = sender.tag
        let isMorning = tag >= 1000 && tag < 2000
        let index = isMorning ? tag - 1000 : tag - 2000

        if isMorning {
            if morningDays.contains(index) { morningDays.remove(index) }
            else { morningDays.insert(index) }
            refreshDayButtons(morningDayButtons, selected: morningDays, countLabel: morningCountLabel)
            onMorningDaysChanged?(morningDays)
        } else {
            if eveningDays.contains(index) { eveningDays.remove(index) }
            else { eveningDays.insert(index) }
            refreshDayButtons(eveningDayButtons, selected: eveningDays, countLabel: eveningCountLabel)
            onEveningDaysChanged?(eveningDays)
        }
    }

    private func refreshDayButtons(_ buttons: [UIButton], selected: Set<Int>, countLabel: UILabel) {
        for (i, btn) in buttons.enumerated() {
            let isOn = selected.contains(i)
            btn.backgroundColor = isOn ? UIColor.ainaCoralPink.withAlphaComponent(0.75) : UIColor.ainaTextTertiary.withAlphaComponent(0.25)
            btn.setTitleColor(isOn ? .white : .ainaTextSecondary, for: .normal)
        }
        countLabel.text = "\(selected.count)/7 days"
    }
}
