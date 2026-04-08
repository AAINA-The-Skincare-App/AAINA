//
//  SkinConditionSectionView.swift
//  AAINA
//

import UIKit

final class SkinConditionSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var pillsContainerStack: UIStackView!
    @IBOutlet private weak var concernsContainerStack: UIStackView!

    // MARK: - Callbacks
    var onConditionSelected: ((String) -> Void)?
    var onConcernsChanged: ((Set<String>) -> Void)?

    // MARK: - State
    // None is first so it appears at the top of the grid
    private let skinConditions = ["Balanced", "Oily", "Dry", "Combination"]
    private let skinConcerns   = ["None", "Dark circles", "Redness", "Dark spots", "Fine lines",
                                  "Acne", "Pigmentation", "Whiteheads", "Blackheads", "Forehead bumps"]

    private var skinConditionButtons = [UIButton]()
    private var concernButtons       = [UIButton]()

    private var expandableRows: [UIStackView] = []
    private var seeMoreButton: UIButton!
    private var isExpanded = false

    private(set) var selectedCondition: String = "" {
        didSet { refreshConditionButtons(); onConditionSelected?(selectedCondition) }
    }
    private(set) var selectedConcerns = Set<String>() {
        didSet { refreshConcernButtons(); onConcernsChanged?(selectedConcerns) }
    }

    // MARK: - Factory
    static func create() -> SkinConditionSectionView {
        let views = Bundle.main.loadNibNamed("SkinConditionSectionView", owner: nil, options: nil)!
        return views.first as! SkinConditionSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        buildConditionPills()
        buildConcernPills()
    }

    // MARK: - Build pills

    private func buildConditionPills() {
        skinConditions.forEach { title in
            let btn = makePill(title: title)
            btn.addTarget(self, action: #selector(conditionTapped(_:)), for: .touchUpInside)
            skinConditionButtons.append(btn)
        }
        layoutPillsInto(pillsContainerStack, buttons: skinConditionButtons)
    }

    private func buildConcernPills() {
        skinConcerns.forEach { title in
            let btn = makePill(title: title)
            btn.addTarget(self, action: #selector(concernTapped(_:)), for: .touchUpInside)
            concernButtons.append(btn)
        }

        concernsContainerStack.axis = .vertical
        concernsContainerStack.spacing = 8
        concernsContainerStack.alignment = .fill

        let visibleCount = 6  // None + first 5 concerns = 3 rows
        let visibleButtons = Array(concernButtons.prefix(visibleCount))
        let hiddenButtons  = Array(concernButtons.dropFirst(visibleCount))

        // Always-visible rows
        for i in stride(from: 0, to: visibleButtons.count, by: 2) {
            let row = makePillRow(Array(visibleButtons[i..<min(i + 2, visibleButtons.count)]))
            concernsContainerStack.addArrangedSubview(row)
        }

        // Expandable rows (hidden behind See more)
        expandableRows = []
        for i in stride(from: 0, to: hiddenButtons.count, by: 2) {
            let row = makePillRow(Array(hiddenButtons[i..<min(i + 2, hiddenButtons.count)]))
            row.isHidden = true
            concernsContainerStack.addArrangedSubview(row)
            expandableRows.append(row)
        }

        // See more button
        seeMoreButton = makeSeeMoreButton()
        concernsContainerStack.addArrangedSubview(seeMoreButton)
    }

    // MARK: - Pill row helpers

    private func makePillRow(_ buttons: [UIButton]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        return row
    }

    private func layoutPillsInto(_ stack: UIStackView, buttons: [UIButton]) {
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        for i in stride(from: 0, to: buttons.count, by: 2) {
            stack.addArrangedSubview(makePillRow(Array(buttons[i..<min(i + 2, buttons.count)])))
        }
    }

    private func makePill(title: String) -> UIButton {
        var cfg = UIButton.Configuration.plain()
        cfg.title = title
        cfg.baseForegroundColor = .ainaTextPrimary
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = .systemFont(ofSize: 13, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: cfg)
        btn.backgroundColor = UIColor.ainaGlassElevated
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.4).cgColor
        btn.heightAnchor.constraint(equalToConstant: 38).isActive = true
        return btn
    }

    private func makeSeeMoreButton() -> UIButton {
        var cfg = UIButton.Configuration.plain()
        cfg.title = "See more"
        cfg.image = UIImage(systemName: "chevron.down",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .medium))
        cfg.imagePlacement = .trailing
        cfg.imagePadding = 4
        cfg.baseForegroundColor = .ainaDustyRose
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = .systemFont(ofSize: 13, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: cfg)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(seeMoreTapped), for: .touchUpInside)
        return btn
    }

    // MARK: - Actions

    @objc private func seeMoreTapped() {
        isExpanded.toggle()
        let chevron = isExpanded ? "chevron.up" : "chevron.down"
        var cfg = seeMoreButton.configuration
        cfg?.title = isExpanded ? "See less" : "See more"
        cfg?.image = UIImage(systemName: chevron,
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .medium))
        seeMoreButton.configuration = cfg

        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
                       options: .allowUserInteraction) {
            self.expandableRows.forEach { $0.isHidden = !self.isExpanded }
            self.concernsContainerStack.superview?.layoutIfNeeded()
        }
    }

    @objc private func conditionTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        selectedCondition = (selectedCondition == title) ? "" : title
    }

    @objc private func concernTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        if title == "None" {
            selectedConcerns = selectedConcerns.contains("None") ? [] : ["None"]
        } else {
            selectedConcerns.remove("None")
            if selectedConcerns.contains(title) { selectedConcerns.remove(title) }
            else { selectedConcerns.insert(title) }
        }
    }

    // MARK: - Refresh

    private func refreshConditionButtons() {
        for btn in skinConditionButtons {
            applyPillStyle(btn, selected: btn.configuration?.title == selectedCondition)
        }
    }

    private func refreshConcernButtons() {
        for btn in concernButtons {
            let title = btn.configuration?.title ?? ""
            applyPillStyle(btn, selected: selectedConcerns.contains(title))
        }
    }

    private func applyPillStyle(_ btn: UIButton, selected: Bool) {
        btn.backgroundColor = selected ? UIColor.ainaCoralPink.withAlphaComponent(0.75) : UIColor.ainaGlassElevated
        btn.layer.borderColor = selected
            ? UIColor.ainaCoralPink.withAlphaComponent(0.75).cgColor
            : UIColor.ainaTextTertiary.withAlphaComponent(0.4).cgColor
        btn.configuration?.baseForegroundColor = selected ? .white : .ainaTextPrimary
    }
}
