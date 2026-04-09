import UIKit

class OnboardingDOBViewController: UIViewController,
                                   UIPickerViewDelegate,
                                   UIPickerViewDataSource {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var dobCardView: UIView!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var privacyContainerView: UIView!
    @IBOutlet weak var privacyIcon: UIImageView!
    @IBOutlet weak var privacyLabel: UILabel!
    // Injected from SceneDelegate
    var dataModel: AppDataModel!

    var onboardingData = OnboardingData()
    var selectedYear: Int? = nil

    let maxYear = 2012
    let minYear = 1900

    var years: [Int] {
        return Array(minYear...maxYear).reversed()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.applyAINABackground()
       
        setupDOBCard()            
        setupPrivacyView()
        setupNextButton()

        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearPicker.setValue(UIColor.ainaTextPrimary, forKey: "textColor")

        selectedYear = nil
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        

        progressView.progressTintColor = .ainaCoralPink
        progressView.trackTintColor = UIColor.ainaRoseLight.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 2

        privacyLabel.textColor = .ainaTextSecondary

        if yearPicker.subviews.count > 1 {
            yearPicker.subviews[1].backgroundColor = UIColor.ainaTintedGlassMedium
        }
    }


    private func setupBlobs() {

        let blob1 = UIView()
        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.25)
        blob1.layer.cornerRadius = 160
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob1)

        let blob2 = UIView()
        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.15)
        blob2.layer.cornerRadius = 130
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob2)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 300),
            blob1.heightAnchor.constraint(equalToConstant: 300),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            blob1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),

            blob2.widthAnchor.constraint(equalToConstant: 250),
            blob2.heightAnchor.constraint(equalToConstant: 250),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60),
            blob2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60)
        ])
    }

    // GLASS CARD

    private func setupDOBCard() {

        dobCardView.backgroundColor = .clear

        // Apply same glass effect as journal
        dobCardView.applyGlass(cornerRadius: 24)

        // Shadow for floating look
        dobCardView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        dobCardView.layer.shadowOpacity = 0.10
        dobCardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        dobCardView.layer.shadowRadius = 20
        dobCardView.layer.masksToBounds = false

        // Optional: premium border
        dobCardView.layer.borderWidth = 1
        dobCardView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }

    // PRIVACY VIEW 

    private func setupPrivacyView() {

        privacyContainerView.backgroundColor = .clear
        privacyContainerView.applyGlass(cornerRadius: 14)

        privacyContainerView.layer.borderWidth = 1
        privacyContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        privacyIcon.tintColor = .ainaCoralPink
        privacyIcon.image = UIImage(systemName: "lock.shield")

        privacyLabel.textColor = UIColor.ainaTextPrimary.withAlphaComponent(0.7)
    }

    // MARK: - BUTTON

    private func setupNextButton() {
        nextButton.backgroundColor = .ainaCoralPink
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 20
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    // MARK: - Picker

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return "\(years[row])"
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        selectedYear = years[row]
        nextButton.isEnabled = true
        nextButton.alpha = 1.0

        print("Selected year:", selectedYear ?? 0)
    }

    // MARK: - Navigation

    @IBAction func nextButtonTapped(_ sender: UIButton) {

        guard let year = selectedYear else {
            print("No year selected")
            return
        }

        onboardingData.birthYear = year
        print("Onboarding data updated:", onboardingData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DobToSkinType",
           let vc = segue.destination as? OnboardingSkinTypeViewController {

            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }
}
