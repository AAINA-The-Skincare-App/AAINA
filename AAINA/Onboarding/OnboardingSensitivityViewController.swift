import UIKit

class OnboardingSensitivityViewController: UIViewController {

    var onboardingData: OnboardingData!
    var dataModel: DataModel!
    

    @IBOutlet var sensitivityButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SensitivityViewController loaded")

        if onboardingData == nil {
            onboardingData = OnboardingData()
        }

        setupButtons()
        setupNextButton()
    }

    // MARK: - Actions

    @IBAction func sensitivityTapped(_ sender: UIButton) {
        let level = sensitivityLevel(from: sender.tag)
        onboardingData.sensitivity = level

        updateSelection(selected: sender)
        enableNextButton()
        provideHaptic()

        print("✅ Sensitivity selected:", level)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard onboardingData.sensitivity != nil else {
            print("❌ No selection")
            return
        }

        //performSegue(withIdentifier: "SensitivityToGoal", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SensitivityToGoal",
           let vc = segue.destination as? OnboardingGoalsViewController {

            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }

    // MARK: - UI Setup

    private func setupButtons() {
        sensitivityButtons.forEach {
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

    // MARK: - Selection UI

    private func updateSelection(selected: UIButton) {
        for button in sensitivityButtons {

            if button == selected {

                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.layer.borderWidth = 1.5

                // 🔥 Tap animation (makes it feel responsive)
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

    // MARK: - Mapping

    private func sensitivityLevel(from tag: Int) -> SensitivityLevel {
        switch tag {
        case 0: return .hardlyEver
        case 1: return .sometimes
        case 2: return .often
        case 3: return .veryEasily
        default: return .sometimes
        }
    }
}
