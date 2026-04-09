//
//  WeeklyCheckInViewController.swift
//  AAINA
//

import UIKit

class WeeklyCheckInViewController: UIViewController {

    // MARK: - Callback
    var onDismiss: (() -> Void)?

    // MARK: - Section views
    private let skinConditionSection   = SkinConditionSectionView.create()
    private let consistencySection     = RoutineConsistencySectionView.create()
    private let lifestyleSection       = LifestyleSectionView.create()
    private let productChangesSection  = ProductChangesSectionView.create()
    private let progressPhotoSection   = ProgressPhotoSectionView.create()
    private let notesSection           = NotesSectionView.create()
    private let changeRoutineSection   = ChangeRoutineSectionView.create()

    // MARK: - Layout
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView    = UIScrollView()
    private let contentStack  = UIStackView()
    private let saveButton    = UIButton(type: .custom)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupHeader()
        setupScrollView()
        addSections()
        setupKeyboard()

        productChangesSection.presentingViewController = self
        progressPhotoSection.presentingViewController  = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyButtonGradient()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Header

    private func setupHeader() {
        titleLabel.text      = "Weekly Check-In"
        titleLabel.font      = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .ainaTextPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text          = "How has your skin been this week?"
        subtitleLabel.font          = .systemFont(ofSize: 15)
        subtitleLabel.textColor     = .ainaTextSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Scroll view

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis    = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    // MARK: - Sections + Save button

    private func addSections() {
        contentStack.addArrangedSubview(skinConditionSection)
        contentStack.addArrangedSubview(consistencySection)
        contentStack.addArrangedSubview(lifestyleSection)
        contentStack.addArrangedSubview(productChangesSection)
        contentStack.addArrangedSubview(progressPhotoSection)
        contentStack.addArrangedSubview(notesSection)
        contentStack.addArrangedSubview(changeRoutineSection)
        contentStack.addArrangedSubview(makeSaveButton())
    }

    private func makeSaveButton() -> UIView {
        saveButton.setTitle("Save Check-In", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font    = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.layer.cornerRadius  = 16
        saveButton.layer.masksToBounds = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return saveButton
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
            self.scrollView.contentInset.bottom = overlap > 0 ? overlap + 8 : 0
        }
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        WeeklyCheckInManager.markCompletedThisWeek()
        onDismiss?()
        dismiss(animated: true)
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
