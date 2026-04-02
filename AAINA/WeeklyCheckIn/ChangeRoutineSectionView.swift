//
//  ChangeRoutineSectionView.swift
//  AAINA
//

import UIKit

final class ChangeRoutineSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var reasonContainer: UIView!
    @IBOutlet private weak var reasonTextView: UITextView!
    @IBOutlet private weak var reasonPlaceholder: UILabel!
    @IBOutlet private weak var warningLabel: UILabel!

    // MARK: - Public
    var routineStartDate: Date = Date()
    var onChangeDecision: ((Bool, String) -> Void)?
    private(set) var wantsChange: Bool = false
    var reason: String { reasonTextView.text ?? "" }

    private let minimumWeeks = 4

    private var cardCollapsedBottom: NSLayoutConstraint?
    private var cardExpandedBottom: NSLayoutConstraint?

    // MARK: - Factory
    static func create() -> ChangeRoutineSectionView {
        let views = Bundle.main.loadNibNamed("ChangeRoutineSectionView", owner: nil, options: nil)!
        return views.first as! ChangeRoutineSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.backgroundColor = .ainaGlassElevated
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        styleButtons()
        configureReasonArea()
        configureWarning()
        reasonContainer.isHidden = true
        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)

        // Find the XIB constraint that pins reasonContainer.bottom → cardView.bottom
        // and replace it with two swappable constraints.
        if let existing = cardView.constraints.first(where: {
            ($0.firstItem as? UIView) == reasonContainer && $0.firstAttribute == .bottom
        }) {
            cardExpandedBottom = existing
        }
        let btnRow = noButton.superview! // the fillEqually button stack
        cardCollapsedBottom = cardView.bottomAnchor.constraint(
            equalTo: btnRow.bottomAnchor, constant: 16)

        setUI(wantsChange: false)
    }

    // MARK: - Style
    private func styleButtons() {
        for btn in [yesButton, noButton] {
            btn?.layer.cornerRadius = 12
            btn?.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        }
    }

    private func configureReasonArea() {
        // Style the text box container so it looks like a visible input field
        let textBox = reasonTextView.superview!
        textBox.backgroundColor = UIColor.ainaGlassElevated
        textBox.layer.cornerRadius = 12
        textBox.layer.borderWidth = 1
        textBox.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.25).cgColor

        reasonTextView.backgroundColor = .clear
        reasonTextView.font = .systemFont(ofSize: 14)
        reasonTextView.textColor = .ainaTextPrimary
        reasonTextView.isScrollEnabled = false
        reasonTextView.textContainerInset = UIEdgeInsets(top: 12, left: 6, bottom: 12, right: 6)
        reasonTextView.delegate = self

        // Give the text box a comfortable minimum height
        let inputBox = reasonTextView.superview!
        inputBox.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true

        // Increase gap between warning and text box
        if let gapConstraint = inputBox.superview?.constraints.first(where: {
            ($0.firstItem as? UIView) == inputBox && $0.firstAttribute == .top
        }) {
            gapConstraint.constant = 16
        }

        reasonPlaceholder.text = "e.g. My skin has stopped responding, I want to try new products..."
        reasonPlaceholder.font = .systemFont(ofSize: 14)
        reasonPlaceholder.textColor = .ainaTextTertiary
        reasonPlaceholder.numberOfLines = 0

        // Align placeholder with where the cursor actually appears:
        // cursor x = textContainerInset.left (6) + lineFragmentPadding (5) = 11
        // cursor y = textContainerInset.top (12)
        let inset = reasonTextView.textContainerInset
        let pad = reasonTextView.textContainer.lineFragmentPadding
        for c in (reasonPlaceholder.superview?.constraints ?? []) {
            if (c.firstItem as? UIView) == reasonPlaceholder {
                if c.firstAttribute == .top     { c.constant = inset.top }
                if c.firstAttribute == .leading  { c.constant = inset.left + pad }
            }
        }
    }

    private func configureWarning() {
        // SF Symbol + indented text via attributed string
        let symbolCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let icon = UIImage(systemName: "exclamationmark.triangle.fill",
                           withConfiguration: symbolCfg)?
            .withTintColor(UIColor.ainaSoftRed, renderingMode: .alwaysOriginal)
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: -2.5, width: 14, height: 14)

        // Paragraph style: headIndent keeps wrapped lines aligned after the icon
        let para = NSMutableParagraphStyle()
        para.headIndent = 22
        para.firstLineHeadIndent = 10
        para.tailIndent = -10
        para.lineSpacing = 2
        para.paragraphSpacing = 2
        para.paragraphSpacingBefore = 2

        // Leading \n + trailing \n create top/bottom breathing room inside the background
        let full = NSMutableAttributedString(string: "\n")
        full.append(NSAttributedString(attachment: attachment))
        full.append(NSAttributedString(string: "  Give your routine more time. Most routines need at least 4 weeks to show results. Consider waiting before making changes.\n"))
        full.addAttributes([
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.ainaSoftRed,
            .paragraphStyle: para
        ], range: NSRange(location: 0, length: full.length))

        warningLabel.attributedText = full
        warningLabel.numberOfLines = 0
        warningLabel.backgroundColor = UIColor.ainaSoftRed.withAlphaComponent(0.1)
        warningLabel.layer.cornerRadius = 10
        warningLabel.layer.masksToBounds = true
        warningLabel.isHidden = true
    }

    // MARK: - Actions
    @IBAction private func yesTapped() {
        wantsChange = true
        setUI(wantsChange: true)
        let weeks = weeksSince(routineStartDate)
        warningLabel.isHidden = weeks >= minimumWeeks
        onChangeDecision?(true, reason)
    }

    @IBAction private func noTapped() {
        wantsChange = false
        setUI(wantsChange: false)
        onChangeDecision?(false, "")
    }

    private func setUI(wantsChange: Bool) {
        // Swap bottom constraints before animating so layout collapses/expands cleanly
        if wantsChange {
            cardCollapsedBottom?.isActive = false
            cardExpandedBottom?.isActive = true
        } else {
            cardExpandedBottom?.isActive = false
            cardCollapsedBottom?.isActive = true
        }

        reasonContainer.isHidden = !wantsChange

        yesButton.backgroundColor = wantsChange
            ? .ainaDustyRose : UIColor.ainaTextTertiary.withAlphaComponent(0.2)
        yesButton.setTitleColor(wantsChange ? .white : .ainaTextSecondary, for: .normal)
        noButton.backgroundColor = wantsChange
            ? UIColor.ainaTextTertiary.withAlphaComponent(0.2) : .ainaDustyRose
        noButton.setTitleColor(wantsChange ? .ainaTextSecondary : .white, for: .normal)

        // Walk up to the scroll content view so the whole layout reflows smoothly
        var target: UIView = self
        while let p = target.superview { target = p }

        UIView.animate(withDuration: 0.28, delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction]) {
            target.layoutIfNeeded()
        }
    }

    // MARK: - Helpers
    private func weeksSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
    }
}

// MARK: - UITextViewDelegate
extension ChangeRoutineSectionView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reasonPlaceholder.isHidden = !textView.text.isEmpty
        onChangeDecision?(wantsChange, reason)
    }
}
