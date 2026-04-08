import UIKit

class OnboardingExposureViewController: UIViewController {

    var onboardingData: OnboardingData!
    var dataModel: AppDataModel!

    @IBOutlet weak var exposureCardView: UIView!
    @IBOutlet var exposureButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!   // Connect this

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setupCard()
        setupNextButton()
    }

    // MARK: - UI Setup

    private func setupCard() {
        exposureCardView.layer.cornerRadius = 22
        exposureCardView.layer.cornerCurve = .continuous

        exposureCardView.backgroundColor = .white   // ✅ match others

        exposureCardView.layer.shadowColor = UIColor.black.cgColor
        exposureCardView.layer.shadowOpacity = 0.06
        exposureCardView.layer.shadowOffset = CGSize(width: 0, height: 6)   // ✅ same as others
        exposureCardView.layer.shadowRadius = 12

        exposureCardView.layer.masksToBounds = false   // ✅ IMPORTANT for shadow
    }

    private func setupButtons() {
        exposureButtons.forEach {
            $0.layer.cornerRadius = 22
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.backgroundColor = .systemBackground
            $0.setTitleColor(.label, for: .normal)
        }
    }

    private func setupNextButton() {
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    private func enableNextButton() {
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }

    // MARK: - Actions

    @IBAction func exposureTapped(_ sender: UIButton) {

        let level = exposureLevel(from: sender.tag)
        onboardingData.uvExposure = level

        updateSelection(selected: sender)
        provideHaptic()
        enableNextButton()
    }

    @IBAction func finishTapped(_ sender: UIButton) {

        guard onboardingData.uvExposure != nil else {
            print("No UV exposure selected")
            return
        }

        saveToUserDefaults(onboardingData)

        let cameraVC = OnboardingCameraViewController()
        cameraVC.onboardingData = onboardingData
        cameraVC.dataModel = dataModel

        navigationController?.pushViewController(cameraVC, animated: true)
    }

    // MARK: - Selection UI

    private func updateSelection(selected: UIButton) {
        for button in exposureButtons {

            if button == selected {

                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.layer.borderWidth = 1.5

                // subtle animation
                UIView.animate(withDuration: 0.15,
                               animations: {
                    button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }) { _ in
                    UIView.animate(withDuration: 0.15) {
                        button.transform = .identity
                    }
                }

            } else {

                button.backgroundColor = .systemBackground
                button.setTitleColor(.label, for: .normal)
                button.layer.borderColor = UIColor.systemGray4.cgColor
                button.layer.borderWidth = 1
            }
        }
    }

    // MARK: - Haptics

    private func provideHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Data

    private func saveToUserDefaults(_ onboardingData: OnboardingData) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(onboardingData) {
            UserDefaults.standard.set(data, forKey: "onboardingData")
        }
    }

    private func exposureLevel(from tag: Int) -> UVExposureLevel {
        switch tag {
        case 0: return .rarely
        case 1: return .moderate
        case 2: return .high
        case 3: return .veryHigh
        default: return .moderate
        }
    }
}
