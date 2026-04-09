//
//  WeeklyCheckInViewController.swift
//  AAINA
//

import UIKit

class WeeklyCheckInViewController: UIViewController {

    // MARK: - Callback
    var onDismiss: (() -> Void)?

    // MARK: - State
    private var selectedRating: Int = 0

    // MARK: - Views
    private let handleBar      = UIView()
    private let titleLabel     = UILabel()
    private let subtitleLabel  = UILabel()
    private let ratingStack    = UIStackView()
    private var ratingButtons  = [UIButton]()
    private let notesCard      = UIView()
    private let notesTextView  = UITextView()
    private let notesPlaceholder = UILabel()
    private let saveButton     = UIButton(type: .custom)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupHandleBar()
        setupHeader()
        setupRating()
        setupNotesCard()
        setupSaveButton()
        setupKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyButtonGradient()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Handle bar

    private func setupHandleBar() {
        handleBar.backgroundColor    = UIColor.systemGray4
        handleBar.layer.cornerRadius = 2.5
        handleBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(handleBar)
        NSLayoutConstraint.activate([
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            handleBar.widthAnchor.constraint(equalToConstant: 36),
            handleBar.heightAnchor.constraint(equalToConstant: 5)
        ])
    }

    // MARK: - Header

    private func setupHeader() {
        titleLabel.text          = "Weekly Check-In"
        titleLabel.font          = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor     = .ainaTextPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text          = "How has your skin been this week?"
        subtitleLabel.font          = .systemFont(ofSize: 15)
        subtitleLabel.textColor     = .ainaTextSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Rating

    private func setupRating() {
        ratingStack.axis         = .horizontal
        ratingStack.distribution = .fillEqually
        ratingStack.spacing      = 8
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingStack)

        let emojis = ["😞", "😕", "😐", "🙂", "🤩"]
        let labels = ["Poor", "Fair", "Okay", "Good", "Great"]

        for i in 0..<5 {
            let container = UIStackView()
            container.axis      = .vertical
            container.alignment = .center
            container.spacing   = 4

            let btn = UIButton(type: .custom)
            btn.setTitle(emojis[i], for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 28)
            btn.backgroundColor  = .ainaTintedGlassMedium
            btn.layer.cornerRadius = 16
            btn.tag = i + 1
            btn.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.heightAnchor.constraint(equalToConstant: 56),
            ])

            let lbl = UILabel()
            lbl.text      = labels[i]
            lbl.font      = .systemFont(ofSize: 11)
            lbl.textColor = .ainaTextTertiary
            lbl.textAlignment = .center

            container.addArrangedSubview(btn)
            container.addArrangedSubview(lbl)
            ratingStack.addArrangedSubview(container)
            ratingButtons.append(btn)
        }

        NSLayoutConstraint.activate([
            ratingStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            ratingStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ratingStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Notes card

    private func setupNotesCard() {
        notesCard.layer.cornerRadius = 20
        notesCard.clipsToBounds      = true
        notesCard.translatesAutoresizingMaskIntoConstraints = false
        notesCard.applyGlass(cornerRadius: 20)
        view.addSubview(notesCard)

        notesTextView.backgroundColor    = .clear
        notesTextView.font               = .systemFont(ofSize: 15)
        notesTextView.textColor          = .ainaTextPrimary
        notesTextView.tintColor          = .ainaCoralPink
        notesTextView.textContainerInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        notesTextView.isScrollEnabled    = false
        notesTextView.delegate           = self
        notesTextView.translatesAutoresizingMaskIntoConstraints = false

        notesPlaceholder.text          = "Any notable changes, reactions or observations this week…"
        notesPlaceholder.font          = .systemFont(ofSize: 15)
        notesPlaceholder.textColor     = .ainaTextTertiary
        notesPlaceholder.numberOfLines = 0
        notesPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        notesCard.addSubview(notesTextView)
        notesCard.addSubview(notesPlaceholder)

        NSLayoutConstraint.activate([
            notesCard.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 20),
            notesCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notesCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            notesTextView.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 16),
            notesTextView.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 16),
            notesTextView.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -16),
            notesTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            notesTextView.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -16),

            notesPlaceholder.topAnchor.constraint(equalTo: notesTextView.topAnchor),
            notesPlaceholder.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 4),
            notesPlaceholder.trailingAnchor.constraint(equalTo: notesTextView.trailingAnchor, constant: -4)
        ])
    }

    // MARK: - Save button

    private func setupSaveButton() {
        saveButton.setTitle("Save Check-In", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font    = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius  = 16
        saveButton.layer.masksToBounds = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func applyButtonGradient() {
        guard saveButton.bounds.width > 0 else { return }
        let name = "saveGradient"
        if let existing = saveButton.layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer {
            existing.frame = saveButton.bounds; return
        }
        let grad          = CAGradientLayer()
        grad.name         = name
        grad.colors       = [UIColor.ainaCoralPink.cgColor, UIColor.ainaDustyRose.cgColor]
        grad.startPoint   = CGPoint(x: 0, y: 0.5)
        grad.endPoint     = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 16
        grad.frame        = saveButton.bounds
        saveButton.layer.insertSublayer(grad, at: 0)
        saveButton.layer.shadowColor   = UIColor.ainaDustyRose.cgColor
        saveButton.layer.shadowOpacity = 0.35
        saveButton.layer.shadowOffset  = CGSize(width: 0, height: 8)
        saveButton.layer.shadowRadius  = 12
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
        let overlap = max(0, view.bounds.maxY - frame.minY)
        UIView.animate(withDuration: duration) {
            self.saveButton.transform = overlap > 0
                ? CGAffineTransform(translationX: 0, y: -(overlap + 8))
                : .identity
        }
    }

    // MARK: - Actions

    @objc private func ratingTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        for (i, btn) in ratingButtons.enumerated() {
            UIView.animate(withDuration: 0.2) {
                btn.backgroundColor = (i + 1 <= self.selectedRating)
                    ? UIColor.ainaCoralPink.withAlphaComponent(0.25)
                    : .ainaTintedGlassMedium
                btn.transform = (i + 1 == self.selectedRating)
                    ? CGAffineTransform(scaleX: 1.15, y: 1.15)
                    : .identity
            }
        }
    }

    @objc private func saveTapped() {
        WeeklyCheckInManager.markCompletedThisWeek()
        onDismiss?()
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension WeeklyCheckInViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - WeeklyCheckInManager

enum WeeklyCheckInManager {
    private static let key = "weeklyCheckIn_lastShownWeek"

    static func shouldShow() -> Bool {
        let stored = UserDefaults.standard.string(forKey: key) ?? ""
        return stored != currentWeekKey()
    }

    static func markCompletedThisWeek() {
        UserDefaults.standard.set(currentWeekKey(), forKey: key)
    }

    static func markShownThisWeek() {
        UserDefaults.standard.set(currentWeekKey(), forKey: key)
    }

    private static func currentWeekKey() -> String {
        let cal  = Calendar.current
        let now  = Date()
        let week = cal.component(.weekOfYear, from: now)
        let year = cal.component(.year, from: now)
        return "\(year)-W\(week)"
    }
}
