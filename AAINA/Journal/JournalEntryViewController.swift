//
//  JournalEntryViewController.swift
//  skinCare
//

import UIKit

class JournalEntryViewController: UIViewController {

    // MARK: - Callback
    var onSave: ((JournalEntry) -> Void)?

    // MARK: - State
    private var isFlareUp = false
    private var selectedTags: Set<String> = []
    private let tagOptions = ["Acne", "Redness", "Dryness", "Sensitivity", "Breakout", "Texture"]

    // MARK: - Outlets
    @IBOutlet weak var notesCard: UIView!
    @IBOutlet weak var notesHeaderButton: UIButton!
    @IBOutlet weak var notesSeparator: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesPlaceholder: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var whatWorsenedContainer: UIView!
    @IBOutlet weak var whatWorsenedLabel: UILabel!
    @IBOutlet weak var tagsGrid: UIStackView!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        notesCard.applyGlass(cornerRadius: 16)
        notesSeparator.backgroundColor = .separator
        notesTextView.delegate = self
        notesTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)

        // Text container corner radius (view is in storyboard, radius applied here)
        if let tc = notesTextView.superview {
            tc.layer.cornerRadius = 12
            tc.clipsToBounds = true
        }

        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = .label

        buildTagsGrid()
        updateFlareUpVisibility(animated: false)
    }

    // MARK: - Tag buttons

    private func buildTagsGrid() {
        tagsGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for row in stride(from: 0, to: tagOptions.count, by: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 10
            for col in 0..<2 {
                let idx = row + col
                guard idx < tagOptions.count else { break }
                rowStack.addArrangedSubview(makeTagButton(tagOptions[idx]))
            }
            tagsGrid.addArrangedSubview(rowStack)
        }
    }

    private func makeTagButton(_ title: String) -> UIView {
        let glass = UIVisualEffectView(effect: UIGlassEffect())
        glass.layer.cornerRadius = 20
        glass.clipsToBounds = true
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        glass.contentView.addSubview(btn)

        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: glass.contentView.topAnchor),
            btn.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor),
            btn.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor)
        ])
        return glass
    }

    // MARK: - IBActions

    @IBAction func notesHeaderTapped(_ sender: Any) {
        navigationController?.pushViewController(NotesEditorViewController(), animated: true)
    }

    @IBAction func checkboxTapped(_ sender: UIButton) {
        isFlareUp.toggle()
        checkboxButton.isSelected = isFlareUp
        updateFlareUpVisibility(animated: true)
    }

    @objc private func tagTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let glass = sender.superview?.superview as? UIVisualEffectView {
            UIView.animate(withDuration: 0.15) {
                glass.backgroundColor = sender.isSelected
                    ? UIColor(red: 0.93, green: 0.45, blue: 0.45, alpha: 0.6)
                    : .clear
            }
        }
        guard let title = sender.title(for: .normal) else { return }
        if sender.isSelected { selectedTags.insert(title) } else { selectedTags.remove(title) }
    }

    @IBAction func saveTapped(_ sender: Any) {
        let text = notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            navigationController?.popViewController(animated: true)
            return
        }

        let now = Date()
        let entry = JournalEntry(
            id: String(now.timeIntervalSince1970),
            userID: "",
            note: text,
            flareUps: Array(selectedTags).sorted(),
            date: now
        )
        onSave?(entry)
        navigationController?.popViewController(animated: true)
    }

    private func updateFlareUpVisibility(animated: Bool) {
        let show = isFlareUp
        if animated {
            if show { whatWorsenedContainer.isHidden = false }
            UIView.animate(withDuration: 0.25, animations: {
                self.whatWorsenedContainer.alpha = show ? 1 : 0
            }) { _ in
                if !show { self.whatWorsenedContainer.isHidden = true }
            }
        } else {
            whatWorsenedContainer.isHidden = !show
            whatWorsenedContainer.alpha = show ? 1 : 0
        }
    }
}

// MARK: - UITextViewDelegate

extension JournalEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholder.isHidden = !textView.text.isEmpty
    }
}
