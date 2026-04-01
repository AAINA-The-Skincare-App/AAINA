//
//  NotesSectionView.swift
//  AAINA
//

import UIKit

final class NotesSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var notesCard: UIView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var placeholderLabel: UILabel!

    // MARK: - Public property
    var notes: String { textView.text ?? "" }

    // MARK: - Factory
    static func create() -> NotesSectionView {
        let views = Bundle.main.loadNibNamed("NotesSectionView", owner: nil, options: nil)!
        return views.first as! NotesSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        notesCard.backgroundColor = .ainaGlassElevated
        notesCard.layer.cornerRadius = 16
        notesCard.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        notesCard.layer.shadowOpacity = 0.08
        notesCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        notesCard.layer.shadowRadius = 8
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .ainaTextPrimary
        textView.isScrollEnabled = false
        textView.delegate = self

        placeholderLabel.text = "Any other observations about your skin, diet, or environment this week..."
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = .ainaTextTertiary
        placeholderLabel.numberOfLines = 0
    }
}

// MARK: - UITextViewDelegate
extension NotesSectionView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
