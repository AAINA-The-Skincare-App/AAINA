import UIKit

class RoutineLoadingViewController: UIViewController {

    var onboardingData: OnboardingData!
    var capturedImage: UIImage?
    var dataModel: DataModel!

    private let spinner = UIActivityIndicatorView(style: .large)
    private let headlineLabel = UILabel()
    private let subLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnalysis()
    }

    // MARK: - UI

    private func setupUI() {
        spinner.color = .label
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        headlineLabel.text = "Analysing your skin…"
        headlineLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        headlineLabel.textAlignment = .center
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false

        subLabel.text = "Building your personalised routine"
        subLabel.font = .systemFont(ofSize: 15)
        subLabel.textColor = .secondaryLabel
        subLabel.textAlignment = .center
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(spinner)
        view.addSubview(headlineLabel)
        view.addSubview(subLabel)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            headlineLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 28),
            headlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            headlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            headlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Gemini Call

    private func startAnalysis() {
        Task {
            do {
                let prompt = RoutinePromptBuilder.build(
                    onboardingData: onboardingData,
                    ingredients: dataModel.allIngredients(),
                    imageProvided: capturedImage != nil
                )

                let output = try await GeminiFreeService().generateRoutine(
                    prompt: prompt,
                    image: capturedImage
                )

                dataModel.saveAIRoutine(output)

                // Build and persist UserProfile with the real login name
                let loginName = UserDefaults.standard.string(forKey: "userName") ?? "User"
                if let profile = UserProfile.from(onboarding: self.onboardingData, name: loginName) {
                    AppDataModel.shared.saveProfile(profile)
                }

                await MainActor.run { transitionToMainApp() }

            } catch {
                await MainActor.run { showFailureAlert() }
            }
        }
    }

    // MARK: - Navigation

    private func transitionToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarViewController"
        ) as? MainTabBarViewController else { return }

        tabBar.dataModel = dataModel

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBar
        }
    }

    private func showFailureAlert() {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: "We couldn't analyse your skin right now.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.startAnalysis()
        })
        alert.addAction(UIAlertAction(title: "Use Default Routine", style: .cancel) { [weak self] _ in
            self?.transitionToMainApp()
        })
        present(alert, animated: true)
    }
}
