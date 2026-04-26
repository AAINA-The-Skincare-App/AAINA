//
//  JournalEntryViewController.swift
//  AAINA
//

import UIKit
import PhotosUI

class JournalEntryViewController: UIViewController {

    // MARK: - Callback
    var onSave: ((JournalEntry) -> Void)?

    // MARK: - State
    private var selectedPhotos  = [UIImage]()
    private var userTags        = [String]()   // custom tags added by user

    // MARK: - Root layout
    private let scrollView   = UIScrollView()
    private let contentView  = UIView()
    private let blob1        = UIView()
    private let blob2        = UIView()

    // Notes card
    private let notesCard        = UIView()
    private let notesTextView    = UITextView()
    private let notesPlaceholder = UILabel()
    private let notesSep         = UIView()

    // Tags card
    private let tagsCard      = UIView()
    private let tagField      = UITextField()
    private let tagsWrap      = UIView()    // wrapping view for pill flow
    private var tagPillStack  = UIStackView()

    // Photos card
    private let photosCard      = UIView()
    private let photoScrollView = UIScrollView()
    private let photoStrip      = UIStackView()

    // Save
    private let saveButton = UIButton(type: .custom)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupNavBar()
        setupBlobs()
        setupScrollView()
        setupNotesCard()
        setupTagsCard()
        setupPhotosCard()
        setupSaveButton()
        setupKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
        applyButtonGradient()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Navigation bar

    private func setupNavBar() {
        title = "My Notes"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Ambient blobs

    private func setupBlobs() {
        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.22)
        blob1.layer.cornerRadius = 150
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob1)

        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.13)
        blob2.layer.cornerRadius = 120
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob2)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 300),
            blob1.heightAnchor.constraint(equalToConstant: 300),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -60),
            blob1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),

            blob2.widthAnchor.constraint(equalToConstant: 240),
            blob2.heightAnchor.constraint(equalToConstant: 240),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            blob2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -50)
        ])

        UIView.animate(withDuration: 8, delay: 0,
                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.blob1.transform = CGAffineTransform(translationX: -18, y: 18).scaledBy(x: 1.05, y: 1.05)
        }
        UIView.animate(withDuration: 10, delay: 1.5,
                       options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.blob2.transform = CGAffineTransform(translationX: 12, y: -20).scaledBy(x: 1.07, y: 1.07)
        }
    }

    // MARK: - Scroll view

    private func setupScrollView() {
        scrollView.alwaysBounceVertical  = true
        scrollView.keyboardDismissMode   = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Notes card

    private func setupNotesCard() {
        notesCard.layer.cornerRadius = 20
        notesCard.clipsToBounds = true
        notesCard.translatesAutoresizingMaskIntoConstraints = false
        notesCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(notesCard)

        let badge  = makeIconBadge(systemName: "note.text")
        let header = makeSectionLabel("NOTE")

        notesTextView.backgroundColor        = .clear
        notesTextView.font                   = .systemFont(ofSize: 15)
        notesTextView.textColor              = .ainaTextPrimary
        notesTextView.tintColor              = .ainaCoralPink
        notesTextView.textContainerInset     = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        notesTextView.isScrollEnabled        = false
        notesTextView.delegate               = self
        notesTextView.translatesAutoresizingMaskIntoConstraints = false

        notesPlaceholder.text          = "Skin tips, product finds, ingredients you love or hate — anything worth remembering..."
        notesPlaceholder.font          = .systemFont(ofSize: 15)
        notesPlaceholder.textColor     = .ainaTextTertiary
        notesPlaceholder.numberOfLines = 0
        notesPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        notesSep.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.15)
        notesSep.translatesAutoresizingMaskIntoConstraints = false

        [badge, header, notesSep, notesPlaceholder, notesTextView].forEach { notesCard.addSubview($0) }

        NSLayoutConstraint.activate([
            notesCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            notesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badge.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 20),
            badge.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 20),

            header.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            header.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),

            notesSep.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 12),
            notesSep.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 20),
            notesSep.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -20),
            notesSep.heightAnchor.constraint(equalToConstant: 1),

            notesTextView.topAnchor.constraint(equalTo: notesSep.bottomAnchor, constant: 12),
            notesTextView.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),
            notesTextView.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -16),
            notesTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            notesTextView.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -16),

            notesPlaceholder.topAnchor.constraint(equalTo: notesTextView.topAnchor),
            notesPlaceholder.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 4),
            notesPlaceholder.trailingAnchor.constraint(equalTo: notesTextView.trailingAnchor, constant: -4)
        ])
    }

    // MARK: - Tags card

    private func setupTagsCard() {
        tagsCard.layer.cornerRadius = 20
        tagsCard.clipsToBounds = true
        tagsCard.translatesAutoresizingMaskIntoConstraints = false
        tagsCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(tagsCard)

        let badge  = makeIconBadge(systemName: "tag.fill")
        let header = makeSectionLabel("TAGS")

        let subtitle = UILabel()
        subtitle.text          = "Add tags to find this note later"
        subtitle.font          = .systemFont(ofSize: 12)
        subtitle.textColor     = .ainaTextSecondary
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        // Tag input row
        let inputContainer = UIView()
        inputContainer.backgroundColor    = UIColor.ainaCoralPink.withAlphaComponent(0.06)
        inputContainer.layer.cornerRadius = 12
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        tagField.placeholder       = "e.g. Products, Tips, Research…"
        tagField.font              = .systemFont(ofSize: 14)
        tagField.textColor         = .ainaTextPrimary
        tagField.tintColor         = .ainaCoralPink
        tagField.returnKeyType     = .done
        tagField.delegate          = self
        tagField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(tagField)

        NSLayoutConstraint.activate([
            inputContainer.heightAnchor.constraint(equalToConstant: 40),
            tagField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            tagField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            tagField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])

        // Pill stack for existing tags (vertical — one tag per row)
        tagPillStack.axis      = .vertical
        tagPillStack.spacing   = 8
        tagPillStack.alignment = .fill
        tagPillStack.translatesAutoresizingMaskIntoConstraints = false

        [badge, header, subtitle, inputContainer, tagPillStack].forEach { tagsCard.addSubview($0) }

        NSLayoutConstraint.activate([
            tagsCard.topAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: 16),
            tagsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badge.topAnchor.constraint(equalTo: tagsCard.topAnchor, constant: 20),
            badge.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 20),

            header.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            header.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),

            subtitle.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: tagsCard.trailingAnchor, constant: -20),

            inputContainer.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 12),
            inputContainer.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: tagsCard.trailingAnchor, constant: -16),

            tagPillStack.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 10),
            tagPillStack.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 16),
            tagPillStack.trailingAnchor.constraint(equalTo: tagsCard.trailingAnchor, constant: -16),
            tagPillStack.bottomAnchor.constraint(equalTo: tagsCard.bottomAnchor, constant: -16)
        ])
    }

    private func rebuildTagPills() {
        tagPillStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, tag) in userTags.enumerated() {
            tagPillStack.addArrangedSubview(makeTagPill(tag, index: i))
        }
        // Force layout update so the card resizes
        tagsCard.setNeedsLayout()
        tagsCard.layoutIfNeeded()
    }

    private func makeTagPill(_ title: String, index: Int) -> UIView {
        let pill = UIView()
        pill.backgroundColor    = UIColor.ainaDustyRose.withAlphaComponent(0.15)
        pill.layer.cornerRadius = 14
        pill.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text      = title
        label.font      = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .ainaDustyRose
        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        let xBtn = UIButton(type: .system)
        xBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        xBtn.tintColor = .ainaDustyRose
        xBtn.tag = index
        xBtn.addTarget(self, action: #selector(removeTag(_:)), for: .touchUpInside)
        xBtn.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(xBtn)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor),

            xBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            xBtn.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            xBtn.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            xBtn.widthAnchor.constraint(equalToConstant: 16),
            xBtn.heightAnchor.constraint(equalToConstant: 28),

            pill.heightAnchor.constraint(equalToConstant: 30)
        ])
        return pill
    }

    // MARK: - Photos card

    private func setupPhotosCard() {
        photosCard.layer.cornerRadius = 20
        photosCard.clipsToBounds      = true
        photosCard.translatesAutoresizingMaskIntoConstraints = false
        photosCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(photosCard)

        let badge    = makeIconBadge(systemName: "paperclip")
        let header   = makeSectionLabel("ATTACHMENTS & PHOTOS")

        let subtitle = UILabel()
        subtitle.text          = "Attach product images, screenshots or references"
        subtitle.font          = .systemFont(ofSize: 12)
        subtitle.textColor     = .ainaTextSecondary
        subtitle.numberOfLines = 1
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        photoScrollView.showsHorizontalScrollIndicator = false
        photoScrollView.translatesAutoresizingMaskIntoConstraints = false

        photoStrip.axis      = .horizontal
        photoStrip.spacing   = 10
        photoStrip.alignment = .center
        photoStrip.translatesAutoresizingMaskIntoConstraints = false
        photoScrollView.addSubview(photoStrip)

        [badge, header, subtitle, photoScrollView].forEach { photosCard.addSubview($0) }

        NSLayoutConstraint.activate([
            photosCard.topAnchor.constraint(equalTo: tagsCard.bottomAnchor, constant: 16),
            photosCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photosCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badge.topAnchor.constraint(equalTo: photosCard.topAnchor, constant: 20),
            badge.leadingAnchor.constraint(equalTo: photosCard.leadingAnchor, constant: 20),

            header.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            header.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),

            subtitle.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: photosCard.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: photosCard.trailingAnchor, constant: -20),

            photoScrollView.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 14),
            photoScrollView.leadingAnchor.constraint(equalTo: photosCard.leadingAnchor),
            photoScrollView.trailingAnchor.constraint(equalTo: photosCard.trailingAnchor),
            photoScrollView.heightAnchor.constraint(equalToConstant: 96),
            photoScrollView.bottomAnchor.constraint(equalTo: photosCard.bottomAnchor, constant: -16),

            photoStrip.topAnchor.constraint(equalTo: photoScrollView.topAnchor),
            photoStrip.leadingAnchor.constraint(equalTo: photoScrollView.leadingAnchor, constant: 16),
            photoStrip.trailingAnchor.constraint(equalTo: photoScrollView.trailingAnchor, constant: -16),
            photoStrip.bottomAnchor.constraint(equalTo: photoScrollView.bottomAnchor),
            photoStrip.heightAnchor.constraint(equalTo: photoScrollView.heightAnchor)
        ])

        rebuildPhotoStrip()
    }

    private func rebuildPhotoStrip() {
        photoStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, image) in selectedPhotos.enumerated() {
            photoStrip.addArrangedSubview(makePhotoTile(image: image, index: i))
        }
        if selectedPhotos.count < 6 {
            photoStrip.addArrangedSubview(makeAddPhotoTile())
        }
    }

    private func makePhotoTile(image: UIImage, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 80),
            container.heightAnchor.constraint(equalToConstant: 80)
        ])

        let iv = UIImageView(image: image)
        iv.contentMode    = .scaleAspectFill
        iv.clipsToBounds  = true
        iv.layer.cornerRadius = 14
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)

        let del = UIButton(type: .system)
        del.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        del.tintColor       = .ainaDustyRose
        del.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        del.layer.cornerRadius = 10
        del.tag = index
        del.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
        del.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(del)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            del.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            del.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            del.widthAnchor.constraint(equalToConstant: 20),
            del.heightAnchor.constraint(equalToConstant: 20)
        ])
        return container
    }

    private func makeAddPhotoTile() -> UIView {
        let tile = JEDashedTileView()
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 80),
            tile.heightAnchor.constraint(equalToConstant: 80)
        ])

        let icon = UIImageView(image: UIImage(systemName: "paperclip"))
        icon.tintColor   = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(icon)

        let lbl = UILabel()
        lbl.text      = "Add"
        lbl.font      = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .ainaDustyRose
        lbl.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(lbl)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: tile.centerYAnchor, constant: -8),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            lbl.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            lbl.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 4)
        ])

        tile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped)))
        return tile
    }

    // MARK: - Save button

    private func setupSaveButton() {
        saveButton.setTitle("Save Note", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font   = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: photosCard.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func applyButtonGradient() {
        guard saveButton.bounds.width > 0 else { return }
        let name = "saveGradient"
        if let existing = saveButton.layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer {
            existing.frame = saveButton.bounds; return
        }
        let grad        = CAGradientLayer()
        grad.name       = name
        grad.colors     = [UIColor.ainaCoralPink.cgColor, UIColor.ainaDustyRose.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 16
        grad.frame      = saveButton.bounds
        saveButton.layer.insertSublayer(grad, at: 0)
        saveButton.layer.shadowColor   = UIColor.ainaDustyRose.cgColor
        saveButton.layer.shadowOpacity = 0.35
        saveButton.layer.shadowOffset  = CGSize(width: 0, height: 8)
        saveButton.layer.shadowRadius  = 12
    }

    // MARK: - Shared helpers

    private func makeIconBadge(systemName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .ainaTintedGlassMedium
        container.layer.cornerRadius = 18
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: systemName))
        icon.tintColor   = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 36),
            container.heightAnchor.constraint(equalToConstant: 36),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
        return container
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.ainaTextTertiary,
            .kern: 1.4
        ])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Keyboard

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardChanged(_ note: Notification) {
        guard let info     = note.userInfo,
              let frame    = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let height = max(0, view.bounds.maxY - frame.minY)
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = height > 0 ? height + 16 : 0
        }
    }

    // MARK: - Actions

    @objc private func addPhotoTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in self?.presentCamera() })
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in self?.presentPicker() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func removePhoto(_ sender: UIButton) {
        guard sender.tag < selectedPhotos.count else { return }
        selectedPhotos.remove(at: sender.tag)
        rebuildPhotoStrip()
    }

    @objc private func removeTag(_ sender: UIButton) {
        guard sender.tag < userTags.count else { return }
        userTags.remove(at: sender.tag)
        rebuildTagPills()
    }

    private func addTag(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !userTags.contains(trimmed) else { return }
        userTags.append(trimmed)
        rebuildTagPills()
    }

    @objc private func saveTapped() {
        let text      = notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileNames = selectedPhotos.compactMap { JournalPhotoStore.save($0) }
        let now       = Date()
        let entry = JournalEntry(
            id:             String(now.timeIntervalSince1970),
            userID:         "",
            note:           text,
            flareUps:       userTags,      // stored in flareUps field as custom tags
            date:           now,
            photoFileNames: fileNames
        )
        onSave?(entry)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension JournalEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholder.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: 0.2) {
            self.notesSep.backgroundColor = textView.text.isEmpty
                ? UIColor.ainaCoralPink.withAlphaComponent(0.15)
                : UIColor.ainaCoralPink.withAlphaComponent(0.5)
        }
    }
}

// MARK: - UITextFieldDelegate (tag input)

extension JournalEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            addTag(text)
            textField.text = nil
        }
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Photo picking

extension JournalEntryViewController: PHPickerViewControllerDelegate,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate {

    fileprivate func presentPicker() {
        var config            = PHPickerConfiguration()
        config.filter         = .images
        config.selectionLimit = max(1, 6 - selectedPhotos.count)
        let picker            = PHPickerViewController(configuration: config)
        picker.delegate       = self
        present(picker, animated: true)
    }

    fileprivate func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let cam           = UIImagePickerController()
        cam.sourceType    = .camera
        cam.allowsEditing = true
        cam.delegate      = self
        present(cam, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        results.prefix(max(0, 6 - selectedPhotos.count)).forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                guard let self, let image = obj as? UIImage else { return }
                DispatchQueue.main.async {
                    self.selectedPhotos.append(image)
                    self.rebuildPhotoStrip()
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            selectedPhotos.append(image)
            rebuildPhotoStrip()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - Dashed tile

private final class JEDashedTileView: UIView {
    private let dash = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor    = UIColor.ainaCoralPink.withAlphaComponent(0.08)
        layer.cornerRadius = 14
        dash.strokeColor   = UIColor.ainaCoralPink.withAlphaComponent(0.4).cgColor
        dash.fillColor     = UIColor.clear.cgColor
        dash.lineWidth     = 1.5
        dash.lineDashPattern = [5, 3]
        layer.addSublayer(dash)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        dash.frame = bounds
        dash.path  = UIBezierPath(roundedRect: bounds, cornerRadius: 14).cgPath
    }
}

