import UIKit

class OnboardingSkinTypeViewController: UIViewController {

    var onboardingData: OnboardingData!
    var dataModel: DataModel!

    @IBOutlet var tZoneButtons: [UIButton]!
    @IBOutlet var uZoneButtons: [UIButton]!
    @IBOutlet var cZoneButtons: [UIButton]!

    @IBOutlet weak var tZoneCardView: UIView!
    @IBOutlet weak var uZoneCardView: UIView!
    @IBOutlet weak var cZoneCardView: UIView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoSubtitleLabel: UILabel!
    @IBOutlet weak var infoDescriptionLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var notSureView: UIView!
    @IBOutlet weak var notSureIcon: UIImageView!
    @IBOutlet weak var notSureLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCards()
        setupButtons(tZoneButtons)
        setupButtons(uZoneButtons)
        setupButtons(cZoneButtons)
        setupNextButton()
        setupPopupUI()
        setupNotSureUI()

        // Initial state
        infoView.isHidden = true
        infoView.alpha = 0

        backgroundView.isHidden = true
        backgroundView.alpha = 0
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        backgroundView.isUserInteractionEnabled = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tap)
        
    }

    // MARK: - Button Actions

    @IBAction func eyeTapped(_ sender: UIButton) {
        print("eye tapped", sender.tag)
        showInfo(for: sender.tag)
    }

    @IBAction func tZoneTapped(_ sender: UIButton) {
        onboardingData.tZone = skinType(from: sender.tag)
        updateSelection(selected: sender, in: tZoneButtons)
        provideHaptic()
        validateSelections()
    }

    @IBAction func uZoneTapped(_ sender: UIButton) {
        onboardingData.uZone = skinType(from: sender.tag)
        updateSelection(selected: sender, in: uZoneButtons)
        provideHaptic()
        validateSelections()
    }

    @IBAction func cZoneTapped(_ sender: UIButton) {
        onboardingData.cZone = skinType(from: sender.tag)
        updateSelection(selected: sender, in: cZoneButtons)
        provideHaptic()
        validateSelections()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard onboardingData.tZone != nil,
              onboardingData.uZone != nil,
              onboardingData.cZone != nil else {
            print("Selection incomplete")
            return
        }

        print("Skin Type Data:", onboardingData)
        // performSegue(withIdentifier: "SkinTypeToSensitivity", sender: self)
    }

    // MARK: - Gesture

    @objc func backgroundTapped() {
        hideInfo()
    }

    // MARK: - Popup Logic

    func showInfo(for tag: Int) {

        view.bringSubviewToFront(backgroundView)
        view.bringSubviewToFront(infoView)

        backgroundView.isUserInteractionEnabled = true

        switch tag {
        case 0:
            infoTitleLabel.text = "T-Zone"
            infoSubtitleLabel.text = "Forehead, Nose & Chin"
            infoDescriptionLabel.text = "This area usually produces more oil compared to other parts of your face."
            infoImageView.image = UIImage(named: "tzone")

        case 1:
            infoTitleLabel.text = "U-Zone"
            infoSubtitleLabel.text = "Cheeks & Jawline"
            infoDescriptionLabel.text = "This area is typically normal to dry and needs hydration."
            infoImageView.image = UIImage(named: "zones")

        case 2:
            infoTitleLabel.text = "C-Zone"
            infoSubtitleLabel.text = "Around Mouth"
            infoDescriptionLabel.text = "This area is prone to dryness and sensitivity."
            infoImageView.image = UIImage(named: "zones")
        default:
            break
        }

        infoView.isHidden = false
        backgroundView.isHidden = false

        infoView.alpha = 0
        backgroundView.alpha = 0

        // Smooth bottom animation (instead of scaling)
        infoView.transform = CGAffineTransform(translationX: 0, y: 30)

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            self.backgroundView.alpha = 1
            self.infoView.alpha = 1
            self.infoView.transform = .identity
        })
    }

    func hideInfo() {
        backgroundView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
            self.infoView.alpha = 0
            self.backgroundView.alpha = 0
            self.infoView.transform = CGAffineTransform(translationX: 0, y: 30)
        }) { _ in
            self.infoView.isHidden = true
            self.backgroundView.isHidden = true
        }
    }

    // MARK: - UI Setup
    private func setupCards() {
        [tZoneCardView, uZoneCardView, cZoneCardView].forEach {

            $0?.backgroundColor = .white
            $0?.layer.cornerRadius = 20
            $0?.layer.cornerCurve = .continuous

            $0?.layer.shadowColor = UIColor.black.cgColor
            $0?.layer.shadowOpacity = 0.06
            $0?.layer.shadowOffset = CGSize(width: 0, height: 6)
            $0?.layer.shadowRadius = 12

            $0?.layer.masksToBounds = false
        }
    }
    private func setupNotSureUI() {
        notSureView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        notSureView.layer.cornerRadius = 14
        notSureView.layer.borderWidth = 1
        notSureView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
    }

    private func setupButtons(_ buttons: [UIButton]) {
        buttons.forEach {
            $0.layer.cornerRadius = 20
            $0.backgroundColor = .systemBackground
            $0.setTitleColor(.label, for: .normal)
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    private func setupNextButton() {
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    // ⭐ POPUP UI DESIGN

    private func setupPopupUI() {

        infoView.backgroundColor = .systemBackground
        infoView.layer.cornerRadius = 20

        // Shadow
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.15
        infoView.layer.shadowOffset = CGSize(width: 0, height: 10)
        infoView.layer.shadowRadius = 25

        // Title
        infoTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        infoTitleLabel.textAlignment = .center

        // Subtitle
        infoSubtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        infoSubtitleLabel.textAlignment = .center
        infoSubtitleLabel.textColor = .secondaryLabel

        // Description
        infoDescriptionLabel.font = UIFont.systemFont(ofSize: 13)
        infoDescriptionLabel.textAlignment = .center
        infoDescriptionLabel.textColor = .secondaryLabel
        infoDescriptionLabel.numberOfLines = 0

        // Icon
        infoImageView.tintColor = .systemBlue
        infoImageView.contentMode = .scaleAspectFit
    }

    // MARK: - Logic

    private func updateSelection(selected: UIButton, in buttons: [UIButton]) {
        for button in buttons {
            if button == selected {

                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

                UIView.animate(withDuration: 0.15,
                               animations: {
                    button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { _ in
                    UIView.animate(withDuration: 0.15) {
                        button.transform = .identity
                    }
                }

            } else {
                button.backgroundColor = .systemBackground
                button.setTitleColor(.label, for: .normal)
                button.layer.borderColor = UIColor.systemGray4.cgColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            }
        }
    }

    private func validateSelections() {
        let isComplete = onboardingData.tZone != nil &&
                         onboardingData.uZone != nil &&
                         onboardingData.cZone != nil

        nextButton.isEnabled = isComplete
        nextButton.alpha = isComplete ? 1.0 : 0.5
    }

    private func provideHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func skinType(from tag: Int) -> SkinType {
        switch tag {
        case 0: return .oily
        case 1: return .normal
        case 2: return .dry
        default: return .normal
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SkinTypeToSensitivity",
           let vc = segue.destination as? OnboardingSensitivityViewController {
            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }
}
