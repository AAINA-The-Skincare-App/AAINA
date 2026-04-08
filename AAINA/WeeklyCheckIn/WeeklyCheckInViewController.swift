//
//  WeeklyCheckInViewController.swift
//  AAINA
//
//  Slim coordinator: creates section views, wires callbacks, handles save/validate.
//

import UIKit

final class WeeklyCheckInViewController: UIViewController {

    // MARK: - Public configuration
    var routineStartDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date()
    var weekStart: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
    var onSave: ((WeeklyCheckInData) -> Void)?

    private let minimumWeeksBeforeChange = 4

    // MARK: - Decorative blobs
    private let blob1 = UIView()
    private let blob2 = UIView()

    // MARK: - Section views (loaded from XIBs)
    private var skinSection      = SkinConditionSectionView.create()
    private var routineSection   = RoutineConsistencySectionView.create()
    private var lifestyleSection = LifestyleSectionView.create()
    private var productSection   = ProductChangesSectionView.create()
    private var photoSection     = ProgressPhotoSectionView.create()
    private var notesSection     = NotesSectionView.create()
    private var changeSection    = ChangeRoutineSectionView.create()

    // MARK: - IBOutlets – Layout
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStack: UIStackView!

    // MARK: - IBOutlets – Nav header
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!

    // MARK: - IBOutlets – Section containers
    @IBOutlet weak var skinSectionContainer: UIView!
    @IBOutlet weak var routineSectionContainer: UIView!
    @IBOutlet weak var lifestyleSectionContainer: UIView!
    @IBOutlet weak var productSectionContainer: UIView!
    @IBOutlet weak var photoSectionContainer: UIView!
    @IBOutlet weak var notesSectionContainer: UIView!
    @IBOutlet weak var changeSectionContainer: UIView!

    // MARK: - IBOutlets – Save
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAINABackground()
        setupBlobs()
        configureScrollView()
        configureNavHeader()
        configureSaveButton()
        embedSections()
        wireSectionCallbacks()
        setupKeyboardDismiss()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
    }

    // MARK: - Configuration

    // MARK: - Decorative Blobs

    private func setupBlobs() {
        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.25)
        blob1.layer.cornerRadius = 160
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blob1, belowSubview: scrollView)

        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.15)
        blob2.layer.cornerRadius = 130
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blob2, belowSubview: scrollView)

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

    private func configureScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.backgroundColor = .clear
    }

    private func configureNavHeader() {
        titleLabel.text = "Weekly check-in"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .ainaTextPrimary

        dateRangeLabel.text = formattedWeekRange()
        dateRangeLabel.font = .systemFont(ofSize: 13)
        dateRangeLabel.textColor = .ainaTextSecondary

        var cfg = UIButton.Configuration.plain()
        cfg.image = UIImage(systemName: "chevron.left")
        cfg.baseForegroundColor = .ainaTextPrimary
        backButton.configuration = cfg
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        backButton.layer.cornerRadius = 20
    }

    private func configureSaveButton() {
        saveButton.setTitle("Save weekly check-in", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = .ainaDustyRose
        saveButton.layer.cornerRadius = 16
    }

    // MARK: - Embed XIB section views into storyboard containers

    private func embedSections() {
        productSection.presentingViewController = self
        photoSection.presentingViewController   = self
        changeSection.routineStartDate          = routineStartDate

        let pairs: [(UIView, UIView)] = [
            (skinSection,      skinSectionContainer),
            (routineSection,   routineSectionContainer),
            (lifestyleSection, lifestyleSectionContainer),
            (productSection,   productSectionContainer),
            (photoSection,     photoSectionContainer),
            (notesSection,     notesSectionContainer),
            (changeSection,    changeSectionContainer)
        ]
        for (section, container) in pairs {
            section.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(section)
            NSLayoutConstraint.activate([
                section.topAnchor.constraint(equalTo: container.topAnchor),
                section.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                section.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                section.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
    }

    // MARK: - Wire callbacks

    private func wireSectionCallbacks() {
    }

    // MARK: - IBActions

    @IBAction func backTapped(_ sender: UIButton) { dismiss(animated: true) }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard validateInputs() else { return }

        var data = WeeklyCheckInData()
        data.weekStart             = weekStart
        data.skinCondition         = skinSection.selectedCondition
        data.concerns              = Array(skinSection.selectedConcerns)
        data.morningDaysCompleted  = Array(routineSection.morningDays)
        data.eveningDaysCompleted  = Array(routineSection.eveningDays)
        data.sleepQuality          = lifestyleSection.selectedSleep + 1
        data.stressLevel           = lifestyleSection.stressLevel
        data.waterIntake           = lifestyleSection.waterGlasses
        data.productChanges        = productSection.productChanges
        data.progressPhoto         = photoSection.selectedImage
        data.additionalNotes       = notesSection.notes
        data.wantsRoutineChange    = changeSection.wantsChange
        data.routineChangeReason   = changeSection.wantsChange ? changeSection.reason : ""

        let weeksActive = weeksSince(routineStartDate)
        if changeSection.wantsChange && weeksActive < minimumWeeksBeforeChange {
            let alert = UIAlertController(
                title: "Are you sure?",
                message: "Your routine has been active for only \(weeksActive) week(s). Experts recommend giving it at least \(minimumWeeksBeforeChange) weeks. Are you sure you want to change it?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Wait and Keep Routine", style: .default))
            alert.addAction(UIAlertAction(title: "Change Anyway", style: .destructive) { [weak self] _ in
                self?.onSave?(data)
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            onSave?(data)
            dismiss(animated: true)
        }
    }

    // MARK: - Validate

    private func validateInputs() -> Bool {
        if skinSection.selectedCondition.isEmpty {
            showAlert(title: "Skin Condition Required",
                      message: "Please select how your skin felt this week.")
            return false
        }
        if changeSection.wantsChange && changeSection.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(title: "Reason Required",
                      message: "Please tell us why you'd like to change your routine.")
            return false
        }
        return true
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func weeksSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
    }

    private func formattedWeekRange() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let end = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let fmtEnd = DateFormatter()
        fmtEnd.dateFormat = "d, yyyy"
        return "\(fmt.string(from: weekStart)) – \(fmtEnd.string(from: end))"
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}

// MARK: - Scheduling helper

extension WeeklyCheckInViewController {
    static func presentIfDue(from presenter: UIViewController,
                             routineStartDate: Date,
                             onSave: @escaping (WeeklyCheckInData) -> Void) {
        let key = "lastWeeklyCheckInDate"
        if let last = UserDefaults.standard.object(forKey: key) as? Date {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            guard days >= 7 else { return }
        }

        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WeeklyCheckInViewController") as! WeeklyCheckInViewController
        vc.routineStartDate = routineStartDate
        vc.weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        vc.onSave = { data in
            UserDefaults.standard.set(Date(), forKey: key)
            onSave(data)
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        presenter.present(vc, animated: true)
    }
}

// MARK: - UILabel letter spacing helper

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attrs = NSMutableAttributedString(string: text)
        attrs.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: attrs.length))
        attributedText = attrs
    }
}
