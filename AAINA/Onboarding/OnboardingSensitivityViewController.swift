import UIKit

class OnboardingSensitivityViewController: UIViewController {

    var onboardingData: OnboardingData!
    var dataModel: DataModel!
    
    @IBOutlet weak var sensitivityCardView: UIView!
    @IBOutlet var sensitivityButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressview: UIProgressView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.applyAINABackground()
        setupCard()

        progressview.progressTintColor = .ainaCoralPink
        progressview.trackTintColor = UIColor.ainaRoseLight.withAlphaComponent(0.3)

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
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard onboardingData.sensitivity != nil else { return }
//        performSegue(withIdentifier: "SensitivityToGoal", sender: self)
    }

    // MARK: - UI Setup

    private func setupCard() {
        sensitivityCardView.backgroundColor = .clear

        sensitivityCardView.applyGlass(cornerRadius: 24)

        sensitivityCardView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        sensitivityCardView.layer.shadowOpacity = 0.10
        sensitivityCardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        sensitivityCardView.layer.shadowRadius = 20
        sensitivityCardView.layer.masksToBounds = false

        sensitivityCardView.layer.borderWidth = 1
        sensitivityCardView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }

    private func setupButtons() {
        sensitivityButtons.forEach {

            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

            $0.configuration = config
            $0.layer.cornerRadius = 22
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.25)

            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.25).cgColor

            $0.setTitleColor(.ainaTextPrimary, for: .normal)
        }
    }

    private func setupNextButton() {
        nextButton.layer.cornerRadius = 20
        nextButton.backgroundColor = .ainaCoralPink
        nextButton.setTitleColor(.white, for: .normal)

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

                button.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.15)
                button.setTitleColor(.ainaCoralPink, for: .normal)

                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.ainaCoralPink.cgColor

                UIView.animate(withDuration: 0.15,
                               animations: {
                    button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }) { _ in
                    UIView.animate(withDuration: 0.15) {
                        button.transform = .identity
                    }
                }

            } else {


                button.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                button.setTitleColor(.ainaTextPrimary, for: .normal)

                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.ainaTextTertiary.withAlphaComponent(0.25).cgColor
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SensitivityToGoal",
           let vc = segue.destination as? OnboardingGoalsViewController {

            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }
}
