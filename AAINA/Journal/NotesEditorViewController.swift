//
//  NotesEditorViewController.swift
//  AAINA
//

import UIKit
import PhotosUI

class NotesEditorViewController: UIViewController {

    // MARK: - Public
    var entry: JournalEntry?
    var onUpdate: ((JournalEntry) -> Void)?

    // MARK: - State
    private var currentPhotoFileNames: [String] = []
    private var newlyAddedPhotos: [UIImage] = []
    private var currentTags: [String] = []

    // MARK: - Views
    private let scrollView      = UIScrollView()
    private let contentView     = UIView()
    private let noteCard        = UIView()
    private let cameraButton    = UIButton(type: .system)
    private let titleField     = UITextField()
    private let dateLabel      = UILabel()
    private let photoSection   = UIView()
    private let photoSep       = UIView()
    private let photoScroll    = UIScrollView()
    private let photoStrip     = UIStackView()
    private let textView       = UITextView()
    private let placeholder    = UILabel()
    private let tagsCard       = UIView()
    private let tagField       = UITextField()
    private var tagPillStack   = UIStackView()
    private var photoSectionHeight: NSLayoutConstraint!
    private var photoSepHeight: NSLayoutConstraint!

    // MARK: - Formatters

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMM"
        return f
    }()

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupNavBar()
        setupScrollView()
        setupNoteCard()
        setupTagsCard()
        subscribeToKeyboard()
        populateFromEntry()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if isMovingFromParent { commitSave() }
    }

    // MARK: - Population

    private func populateFromEntry() {
        guard let entry else {
            dateLabel.text = formattedDate(Date())
            return
        }
        titleField.text = entry.title
        dateLabel.text  = formattedDate(entry.date)
        if !entry.note.isEmpty {
            textView.text = entry.note
            placeholder.isHidden = true
        }
        currentPhotoFileNames = entry.photoFileNames
        rebuildPhotoStrip()
        currentTags = entry.flareUps
        rebuildTagPills()
    }

    private func formattedDate(_ date: Date) -> String {
        let dayPart  = Calendar.current.isDateInToday(date) ? "Today" : Self.dateFmt.string(from: date)
        let timePart = Self.timeFmt.string(from: date)
        return "\(dayPart) · \(timePart)"
    }

    // MARK: - Save

    private func commitSave() {
        guard var entry else { return }
        // Commit any tag the user typed but didn't press Return on
        if let pending = tagField.text {
            addTag(pending)
            tagField.text = nil
        }
        let newTitle     = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newNote      = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let newFileNames = newlyAddedPhotos.compactMap { JournalPhotoStore.save($0) }
        entry.title          = newTitle
        entry.note           = newNote
        entry.flareUps       = currentTags
        entry.photoFileNames = currentPhotoFileNames + newFileNames
        onUpdate?(entry)
    }

    // MARK: - Navigation bar

    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        title = "My Note"

        let backBtn  = makeNavButton(icon: "chevron.left",        action: #selector(backTapped))
        let shareBtn = makeNavButton(icon: "square.and.arrow.up",  action: #selector(shareTapped))
        navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: backBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
    }

    private func makeNavButton(icon: String, action: Selector) -> UIView {
        let glass = UIVisualEffectView(effect: UIGlassEffect())
        glass.layer.cornerRadius = 18
        glass.clipsToBounds = true
        glass.frame = CGRect(x: 0, y: 0, width: 36, height: 36)

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: action, for: .touchUpInside)
        glass.contentView.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: glass.contentView.topAnchor),
            btn.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor),
            btn.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor)
        ])
        return glass
    }

    // MARK: - Scroll view

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode  = .interactive
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

    // MARK: - Note card

    private func setupNoteCard() {
        noteCard.translatesAutoresizingMaskIntoConstraints = false
        noteCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(noteCard)

        // — Title field —
        titleField.placeholder   = "Title"
        titleField.font          = .systemFont(ofSize: 26, weight: .bold)
        titleField.textColor     = .label
        titleField.tintColor     = .ainaCoralPink
        titleField.borderStyle   = .none
        titleField.returnKeyType = .next
        titleField.translatesAutoresizingMaskIntoConstraints = false

        // — Date label —
        dateLabel.font      = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // — Inline camera button —
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.tintColor = UIColor.ainaDustyRose.withAlphaComponent(0.7)
        cameraButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        // — Photo section (hidden when no photos) —
        photoSection.clipsToBounds = true
        photoSection.translatesAutoresizingMaskIntoConstraints = false

        photoScroll.showsHorizontalScrollIndicator = false
        photoScroll.translatesAutoresizingMaskIntoConstraints = false
        photoSection.addSubview(photoScroll)

        photoStrip.axis      = .horizontal
        photoStrip.spacing   = 10
        photoStrip.alignment = .center
        photoStrip.translatesAutoresizingMaskIntoConstraints = false
        photoScroll.addSubview(photoStrip)

        NSLayoutConstraint.activate([
            photoScroll.topAnchor.constraint(equalTo: photoSection.topAnchor, constant: 8),
            photoScroll.leadingAnchor.constraint(equalTo: photoSection.leadingAnchor),
            photoScroll.trailingAnchor.constraint(equalTo: photoSection.trailingAnchor),
            photoScroll.bottomAnchor.constraint(equalTo: photoSection.bottomAnchor, constant: -8),
            photoStrip.topAnchor.constraint(equalTo: photoScroll.topAnchor),
            photoStrip.leadingAnchor.constraint(equalTo: photoScroll.leadingAnchor, constant: 20),
            photoStrip.trailingAnchor.constraint(equalTo: photoScroll.trailingAnchor, constant: -20),
            photoStrip.bottomAnchor.constraint(equalTo: photoScroll.bottomAnchor),
            photoStrip.heightAnchor.constraint(equalTo: photoScroll.heightAnchor)
        ])

        photoSectionHeight = photoSection.heightAnchor.constraint(equalToConstant: 0)
        photoSectionHeight.isActive = true

        // — Separator between photos and body —
        photoSep.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.15)
        photoSep.translatesAutoresizingMaskIntoConstraints = false
        photoSepHeight = photoSep.heightAnchor.constraint(equalToConstant: 0)
        photoSepHeight.isActive = true

        // — Body text view —
        textView.backgroundColor    = .clear
        textView.font               = .systemFont(ofSize: 16)
        textView.textColor          = .label
        textView.tintColor          = .ainaCoralPink
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 20, bottom: 24, right: 20)
        textView.isScrollEnabled    = false
        textView.delegate           = self
        textView.translatesAutoresizingMaskIntoConstraints = false

        placeholder.text          = "Write your thoughts, skin tips, observations…"
        placeholder.font          = .systemFont(ofSize: 16)
        placeholder.textColor     = .tertiaryLabel
        placeholder.numberOfLines = 0
        placeholder.translatesAutoresizingMaskIntoConstraints = false

        [titleField, dateLabel, cameraButton,
         photoSection, photoSep, textView, placeholder].forEach { noteCard.addSubview($0) }

        NSLayoutConstraint.activate([
            noteCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            noteCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noteCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleField.topAnchor.constraint(equalTo: noteCard.topAnchor, constant: 22),
            titleField.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 20),

            cameraButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            cameraButton.widthAnchor.constraint(equalToConstant: 18),
            cameraButton.heightAnchor.constraint(equalToConstant: 18),

            photoSection.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            photoSection.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor),
            photoSection.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor),

            photoSep.topAnchor.constraint(equalTo: photoSection.bottomAnchor),
            photoSep.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 20),
            photoSep.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: photoSep.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            textView.bottomAnchor.constraint(equalTo: noteCard.bottomAnchor, constant: -16),

            placeholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 24),
            placeholder.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Photo strip

    private func rebuildPhotoStrip() {
        photoStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (i, name) in currentPhotoFileNames.enumerated() {
            if let img = JournalPhotoStore.load(named: name) {
                photoStrip.addArrangedSubview(makePhotoTile(image: img, tag: i, isExisting: true))
            }
        }
        let offset = currentPhotoFileNames.count
        for (i, img) in newlyAddedPhotos.enumerated() {
            photoStrip.addArrangedSubview(makePhotoTile(image: img, tag: offset + i, isExisting: false))
        }

        let total = currentPhotoFileNames.count + newlyAddedPhotos.count
        let hasPhotos = total > 0
        if hasPhotos && total < 10 { photoStrip.addArrangedSubview(makeAddPhotoTile()) }

        photoSectionHeight.constant = hasPhotos ? 100 : 0
        photoSepHeight.constant     = hasPhotos ? 1   : 0
        photoSep.backgroundColor   = UIColor.ainaCoralPink.withAlphaComponent(hasPhotos ? 0.15 : 0)

        UIView.animate(withDuration: 0.2) { self.noteCard.layoutIfNeeded() }
    }

    private func makePhotoTile(image: UIImage, tag: Int, isExisting: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 80),
            container.heightAnchor.constraint(equalToConstant: 80)
        ])
        let iv = UIImageView(image: image)
        iv.contentMode      = .scaleAspectFill
        iv.clipsToBounds    = true
        iv.layer.cornerRadius = 14
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)

        let del = UIButton(type: .system)
        del.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        del.tintColor          = .ainaDustyRose
        del.backgroundColor    = UIColor.white.withAlphaComponent(0.85)
        del.layer.cornerRadius = 10
        del.tag = tag
        del.addTarget(self,
                      action: isExisting ? #selector(removeExistingPhoto(_:)) : #selector(removeNewPhoto(_:)),
                      for: .touchUpInside)
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
        let tile = NEDashedTileView()
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 80),
            tile.heightAnchor.constraint(equalToConstant: 80)
        ])
        let icon = UIImageView(image: UIImage(systemName: "plus"))
        icon.tintColor   = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(icon)

        let lbl = UILabel()
        lbl.text      = "Add Photo"
        lbl.font      = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = .ainaDustyRose
        lbl.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(lbl)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: tile.centerYAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            lbl.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            lbl.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 4)
        ])
        tile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped)))
        return tile
    }

    // MARK: - Tags card

    private func setupTagsCard() {
        tagsCard.translatesAutoresizingMaskIntoConstraints = false
        tagsCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(tagsCard)

        let badge  = makeIconBadge(systemName: "tag.fill")
        let header = makeSectionLabel("TAGS")

        let subtitle = UILabel()
        subtitle.text      = "Add tags to find this note later"
        subtitle.font      = .systemFont(ofSize: 12)
        subtitle.textColor = .secondaryLabel
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let inputContainer = UIView()
        inputContainer.backgroundColor    = UIColor.ainaCoralPink.withAlphaComponent(0.06)
        inputContainer.layer.cornerRadius = 12
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        tagField.placeholder   = "e.g. Products, Tips, Research…"
        tagField.font          = .systemFont(ofSize: 14)
        tagField.textColor     = .label
        tagField.tintColor     = .ainaCoralPink
        tagField.returnKeyType = .done
        tagField.delegate      = self
        tagField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(tagField)

        tagPillStack.axis      = .vertical
        tagPillStack.spacing   = 8
        tagPillStack.alignment = .fill
        tagPillStack.translatesAutoresizingMaskIntoConstraints = false

        [badge, header, subtitle, inputContainer, tagPillStack].forEach { tagsCard.addSubview($0) }

        NSLayoutConstraint.activate([
            tagsCard.topAnchor.constraint(equalTo: noteCard.bottomAnchor, constant: 16),
            tagsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tagsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

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
            inputContainer.heightAnchor.constraint(equalToConstant: 40),

            tagField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            tagField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            tagField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),

            tagPillStack.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 10),
            tagPillStack.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 16),
            tagPillStack.trailingAnchor.constraint(equalTo: tagsCard.trailingAnchor, constant: -16),
            tagPillStack.bottomAnchor.constraint(equalTo: tagsCard.bottomAnchor, constant: -16)
        ])
    }

    private func rebuildTagPills() {
        tagPillStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, tag) in currentTags.enumerated() {
            tagPillStack.addArrangedSubview(makeTagPill(tag, index: i))
        }
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
            pill.heightAnchor.constraint(equalToConstant: 30),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            xBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            xBtn.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            xBtn.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            xBtn.widthAnchor.constraint(equalToConstant: 16),
            xBtn.heightAnchor.constraint(equalToConstant: 28)
        ])
        return pill
    }

    @objc private func removeTag(_ sender: UIButton) {
        guard sender.tag < currentTags.count else { return }
        currentTags.remove(at: sender.tag)
        rebuildTagPills()
    }

    private func addTag(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !currentTags.contains(trimmed) else { return }
        currentTags.append(trimmed)
        rebuildTagPills()
    }

    // MARK: - Shared helpers

    private func makeIconBadge(systemName: String) -> UIView {
        let container = UIView()
        container.backgroundColor    = .ainaTintedGlassMedium
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
            .foregroundColor: UIColor.secondaryLabel,
            .kern: 1.4
        ])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSeparator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.15)
        sep.translatesAutoresizingMaskIntoConstraints = false
        return sep
    }

    // MARK: - Keyboard

    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        guard
            let info          = note.userInfo,
            let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration      = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw      = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardHeight = max(0, view.bounds.maxY - keyboardFrame.minY)
        let scrollInset: CGFloat = keyboardHeight > 0 ? keyboardHeight + 16 : 0

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.scrollView.contentInset.bottom = scrollInset
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareTapped() {
        let text = [titleField.text ?? "", textView.text ?? ""]
            .filter { !$0.isEmpty }.joined(separator: "\n\n")
        guard !text.isEmpty else { return }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }

    @objc private func addPhotoTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera",       style: .default) { [weak self] _ in self?.presentCamera() })
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in self?.presentPicker() })
        sheet.addAction(UIAlertAction(title: "Cancel",        style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func removeExistingPhoto(_ sender: UIButton) {
        guard sender.tag < currentPhotoFileNames.count else { return }
        currentPhotoFileNames.remove(at: sender.tag)
        rebuildPhotoStrip()
    }

    @objc private func removeNewPhoto(_ sender: UIButton) {
        let idx = sender.tag - currentPhotoFileNames.count
        guard idx >= 0, idx < newlyAddedPhotos.count else { return }
        newlyAddedPhotos.remove(at: idx)
        rebuildPhotoStrip()
    }
}

// MARK: - UITextViewDelegate

extension NotesEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UITextFieldDelegate (tag input)

extension NotesEditorViewController: UITextFieldDelegate {
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

extension NotesEditorViewController: PHPickerViewControllerDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate {

    fileprivate func presentPicker() {
        let total = currentPhotoFileNames.count + newlyAddedPhotos.count
        var config            = PHPickerConfiguration()
        config.filter         = .images
        config.selectionLimit = max(1, 10 - total)
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
        let total = currentPhotoFileNames.count + newlyAddedPhotos.count
        results.prefix(max(0, 10 - total)).forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                guard let self, let image = obj as? UIImage else { return }
                DispatchQueue.main.async {
                    self.newlyAddedPhotos.append(image)
                    self.rebuildPhotoStrip()
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            newlyAddedPhotos.append(image)
            rebuildPhotoStrip()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - Dashed tile

private final class NEDashedTileView: UIView {
    private let dash = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor      = UIColor.ainaCoralPink.withAlphaComponent(0.08)
        layer.cornerRadius   = 14
        dash.strokeColor     = UIColor.ainaCoralPink.withAlphaComponent(0.4).cgColor
        dash.fillColor       = UIColor.clear.cgColor
        dash.lineWidth       = 1.5
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
