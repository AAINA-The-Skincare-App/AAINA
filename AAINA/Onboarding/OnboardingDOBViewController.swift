import UIKit

class OnboardingDOBViewController: UIViewController,
                                   UIPickerViewDelegate,
                                   UIPickerViewDataSource {

    @IBOutlet weak var dobCardView: UIView!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var privacyContainerView: UIView!
    @IBOutlet weak var privacyIcon: UIImageView!
    @IBOutlet weak var privacyLabel: UILabel!
    // Injected from SceneDelegate
    var dataModel: AppDataModel!

    // Onboarding state
    var onboardingData = OnboardingData()
    var selectedYear: Int? = nil

    // Year range (MAX = 2012, going backwards)
    let maxYear = 2012
    let minYear = 1900

    var years: [Int] {
        return Array(minYear...maxYear).reversed()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPrivacyView()

        print("Running DOBViewController:", ObjectIdentifier(self))

        yearPicker.delegate = self
        yearPicker.dataSource = self

        // ❌ No default selection
        selectedYear = nil

        // Disable Next button initially
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        dobCardView.layer.cornerRadius = 20
        dobCardView.clipsToBounds = true
    }

    // MARK: - PickerView DataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }

    // MARK: - PickerView Delegate

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return "\(years[row])"
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        selectedYear = years[row]

        // Enable Next button after selection
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

        // performSegue(withIdentifier: "DobToSkinType", sender: self)
    }
    private func setupPrivacyView() {

        // Background color (light blue like your design)
        privacyContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)

        // Rounded corners
        privacyContainerView.layer.cornerRadius = 14

        // Shadow
        privacyContainerView.layer.shadowColor = UIColor.black.cgColor
        privacyContainerView.layer.shadowOpacity = 0.05
        privacyContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        privacyContainerView.layer.shadowRadius = 6

        // Important: allow shadow
        privacyContainerView.layer.masksToBounds = false

        // Icon styling
        privacyIcon.tintColor = .systemBlue
        privacyIcon.image = UIImage(systemName: "shield.fill")

        // Label styling
        privacyLabel.textColor = .secondaryLabel
        privacyLabel.font = UIFont.systemFont(ofSize: 13)
        privacyLabel.numberOfLines = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "DobToSkinType",
           let vc = segue.destination as? OnboardingSkinTypeViewController {

            vc.onboardingData = onboardingData
            vc.dataModel = dataModel
        }
    }
}
