//
//  AddReminderViewController.swift
//  skinCare
//

import UIKit
import UserNotifications

class AddReminderViewController: UIViewController {

    // MARK: - Callback
    var onSave: ((String, Date) -> Void)?

    // MARK: - Views
    private let scrollView   = UIScrollView()
    private let contentView  = UIView()
    private let titleCard    = UIView()
    private let titleField   = UITextField()
    private let titleSep     = UIView()
    private let dateCard     = UIView()
    private let datePicker   = UIDatePicker()
    private let saveButton   = UIButton(type: .custom)
    private let blob1        = UIView()
    private let blob2        = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupBlobs()
        setupNavigation()
        setupScrollView()
        setupTitleCard()
        setupDateCard()
        setupSaveButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
        applyButtonGradient()
    }

    // MARK: - Navigation

    private func setupNavigation() {
        title = "New Reminder"
        navigationController?.navigationBar.prefersLargeTitles = true

        let cancelBtn = UIBarButtonItem(
            title: "Cancel", style: .plain,
            target: self, action: #selector(cancelTapped)
        )
        cancelBtn.tintColor = .ainaDustyRose
        navigationItem.leftBarButtonItem = cancelBtn
    }

    // MARK: - Decorative Blobs

    private func setupBlobs() {
        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.25)
        blob1.layer.cornerRadius = 160
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob1)

        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.15)
        blob2.layer.cornerRadius = 130
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob2)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 320),
            blob1.heightAnchor.constraint(equalToConstant: 320),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            blob1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),

            blob2.widthAnchor.constraint(equalToConstant: 260),
            blob2.heightAnchor.constraint(equalToConstant: 260),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60),
            blob2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60)
        ])

        UIView.animate(
            withDuration: 8, delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) { self.blob1.transform = CGAffineTransform(translationX: -20, y: 20).scaledBy(x: 1.05, y: 1.05) }

        UIView.animate(
            withDuration: 10, delay: 1,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) { self.blob2.transform = CGAffineTransform(translationX: 15, y: -25).scaledBy(x: 1.08, y: 1.08) }
    }

    // MARK: - Scroll View

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
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

    // MARK: - Title Card

    private func setupTitleCard() {
        titleCard.layer.cornerRadius = 20
        titleCard.clipsToBounds = true
        titleCard.translatesAutoresizingMaskIntoConstraints = false
        titleCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(titleCard)

        let badge = makeIconBadge(systemName: "bell.fill")
        let header = makeSectionLabel("REMINDER TITLE")

        titleField.placeholder = "e.g. Apply SPF before going out"
        titleField.font = .systemFont(ofSize: 17, weight: .medium)
        titleField.textColor = .ainaTextPrimary
        titleField.attributedPlaceholder = NSAttributedString(
            string: "e.g. Apply SPF before going out",
            attributes: [.foregroundColor: UIColor.ainaTextTertiary]
        )
        titleField.returnKeyType = .done
        titleField.clearButtonMode = .whileEditing
        titleField.tintColor = .ainaCoralPink
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)

        titleSep.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.15)
        titleSep.translatesAutoresizingMaskIntoConstraints = false

        [badge, header, titleField, titleSep].forEach { titleCard.addSubview($0) }

        NSLayoutConstraint.activate([
            titleCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badge.topAnchor.constraint(equalTo: titleCard.topAnchor, constant: 20),
            badge.leadingAnchor.constraint(equalTo: titleCard.leadingAnchor, constant: 20),

            header.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            header.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),

            titleField.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: titleCard.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: titleCard.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            titleSep.topAnchor.constraint(equalTo: titleField.bottomAnchor),
            titleSep.leadingAnchor.constraint(equalTo: titleCard.leadingAnchor, constant: 20),
            titleSep.trailingAnchor.constraint(equalTo: titleCard.trailingAnchor, constant: -20),
            titleSep.heightAnchor.constraint(equalToConstant: 1),
            titleSep.bottomAnchor.constraint(equalTo: titleCard.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Date Card

    private func setupDateCard() {
        dateCard.layer.cornerRadius = 20
        dateCard.clipsToBounds = true
        dateCard.translatesAutoresizingMaskIntoConstraints = false
        dateCard.applyGlass(cornerRadius: 20)
        contentView.addSubview(dateCard)

        let badge  = makeIconBadge(systemName: "calendar")
        let header = makeSectionLabel("DATE & TIME")

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = .ainaCoralPink
        datePicker.minimumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        [badge, header, datePicker].forEach { dateCard.addSubview($0) }

        NSLayoutConstraint.activate([
            dateCard.topAnchor.constraint(equalTo: titleCard.bottomAnchor, constant: 16),
            dateCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badge.topAnchor.constraint(equalTo: dateCard.topAnchor, constant: 20),
            badge.leadingAnchor.constraint(equalTo: dateCard.leadingAnchor, constant: 20),

            header.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            header.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),

            datePicker.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: dateCard.leadingAnchor, constant: 12),
            datePicker.trailingAnchor.constraint(equalTo: dateCard.trailingAnchor, constant: -12),
            datePicker.bottomAnchor.constraint(equalTo: dateCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Save Button

    private func setupSaveButton() {
        saveButton.setTitle("Save Reminder", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius = 16
        saveButton.layer.masksToBounds = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: dateCard.bottomAnchor, constant: 24),
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
            existing.frame = saveButton.bounds
            return
        }
        let grad = CAGradientLayer()
        grad.name = name
        grad.colors = [UIColor.ainaCoralPink.cgColor, UIColor.ainaDustyRose.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 16
        grad.frame = saveButton.bounds
        saveButton.layer.insertSublayer(grad, at: 0)
        saveButton.layer.shadowColor   = UIColor.ainaDustyRose.cgColor
        saveButton.layer.shadowOpacity = 0.35
        saveButton.layer.shadowOffset  = CGSize(width: 0, height: 8)
        saveButton.layer.shadowRadius  = 12
    }

    // MARK: - Helpers

    private func makeIconBadge(systemName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .ainaTintedGlassMedium
        container.layer.cornerRadius = 18
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: systemName))
        icon.tintColor = .ainaDustyRose
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

    // MARK: - Actions

    @objc private func titleChanged() {
        let hasText = !(titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        UIView.animate(withDuration: 0.2) {
            self.titleSep.backgroundColor = hasText
                ? UIColor.ainaCoralPink.withAlphaComponent(0.5)
                : UIColor.ainaCoralPink.withAlphaComponent(0.15)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.duration = 0.4
            anim.values = [-8, 8, -6, 6, -4, 4, 0]
            titleCard.layer.add(anim, forKey: "shake")
            titleField.becomeFirstResponder()
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        onSave?(title, datePicker.date)
        dismiss(animated: true)
    }
}
