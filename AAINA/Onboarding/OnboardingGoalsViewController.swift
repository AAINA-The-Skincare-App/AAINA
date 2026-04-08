import UIKit

class OnboardingGoalsViewController: UIViewController {

    var onboardingData: OnboardingData!
    var dataModel: AppDataModel!

    @IBOutlet var goalButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet var goalsCard: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GoalsViewController loaded")
        setupButtons()
    }

    @IBAction func goalTapped(_ sender: UIButton) {

        let goal = goalFrom(tag: sender.tag)

        if goal == .routineOnly {
            onboardingData.goals.removeAll()
            onboardingData.goals.append(.routineOnly)

        } else {
            onboardingData.goals.removeAll { $0 == .routineOnly }

            if onboardingData.goals.contains(goal) {
                onboardingData.goals.removeAll { $0 == goal }
            } else {
                onboardingData.goals.append(goal)
            }
        }

        updateAllButtons()
        validateNextButton()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard !onboardingData.goals.isEmpty else { return }
        performSegue(withIdentifier: "GoalToWork", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoalToWork",
           let vc = segue.destination as? OnboardingExposureViewController {
            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }

    private func setupButtons() {
        goalButtons.forEach {
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.backgroundColor = .systemBackground
            $0.setTitleColor(.label, for: .normal)
        }
    }

    private func updateButtonState(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            button.setTitleColor(.systemBlue, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            button.backgroundColor = .systemBackground
            button.setTitleColor(.label, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
//        private func setupCards() {
//            goalsCard.forEach { card in
//                card.layer.cornerRadius = 20
//                card.layer.cornerCurve = .continuous
//                card.backgroundColor = .white
//    
//                card.layer.shadowColor = UIColor.black.cgColor
//                card.layer.shadowOpacity = 0.06
//                card.layer.shadowOffset = CGSize(width: 0, height: 6)
//                card.layer.shadowRadius = 12
//                card.layer.masksToBounds = false
//            }
//        }


    private func toggleGoal(_ goal: SkinGoal) {
        if onboardingData.goals.contains(goal) {
            onboardingData.goals.removeAll { $0 == goal }
        } else {
            onboardingData.goals.append(goal)
        }
    }
    private func setupNextButton() {
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    private func validateNextButton() {
        let hasSelection = !onboardingData.goals.isEmpty
        nextButton.isEnabled = hasSelection
        nextButton.alpha = hasSelection ? 1.0 : 0.5
    }
    private func updateAllButtons() {
        for button in goalButtons {

            let goal = goalFrom(tag: button.tag)
            let isSelected = onboardingData.goals.contains(goal)

            updateButtonState(button, isSelected: isSelected)
        }
    }
    
//    private func updateButtonState(_ button: UIButton, isSelected: Bool) {
//
//        var config = button.configuration
//
//        if isSelected {
//            config?.baseForegroundColor = .systemBlue
//            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
//            button.layer.borderWidth = 2
//            button.layer.borderColor = UIColor.systemBlue.cgColor
//
//        } else {
//            config?.baseForegroundColor = .label
//            button.backgroundColor = .clear
//            button.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.systemGray5.cgColor
//        }
//
//        button.configuration = config
//    }


    private func goalFrom(tag: Int) -> SkinGoal {
        switch tag {
        case 0: return .maintainSkin
        case 1: return .hydration
        case 2: return .oilControl
        case 3: return .glow
        case 4: return .toneImprove
        case 5: return .antiAging
        case 6: return .poreMinimize
        case 7: return .routineOnly
        default: return .routineOnly
        }
    }
}
