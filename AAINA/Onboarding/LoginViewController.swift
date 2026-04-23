import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Lottie

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var privacyLabel: UILabel!

    // Lottie view — added in code since storyboard cant render it directly
    private var animationView: LottieAnimationView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupLottieAnimation()
        styleButtons()
    }

    // MARK: - Background
    // light pink matching app theme
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.90, blue: 0.92, alpha: 1)
    }

    // MARK: - Lottie Animation
    // adding lottie on top of the outlet container view
    private func setupLottieAnimation() {
        animationView = LottieAnimationView(name: "face_animation")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundColor = .clear
        animationView.isOpaque = false
        animationView.play()

        animationContainerView.addSubview(animationView)

        // pin lottie to fill the container view fully
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: animationContainerView.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: animationContainerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: animationContainerView.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: animationContainerView.bottomAnchor)
        ])
    }

    // MARK: - Button Styling
    // styling done in code since storyboard doesnt handle corner radius well
    private func styleButtons() {
        appleButton.layer.cornerRadius = 14
        appleButton.clipsToBounds = true

        googleButton.layer.cornerRadius = 14
        googleButton.layer.borderWidth = 1
        googleButton.layer.borderColor = UIColor.lightGray.cgColor
        googleButton.clipsToBounds = true
    }

    // MARK: - Google Login
    @IBAction func googleTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("missing clientID from firebase")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("google sign in error:", error.localizedDescription)
                return
            }

            guard let user = result?.user else { return }
            let name = user.profile?.name ?? "User"
            self.saveLogin(name: name)
            self.goToOnboarding()
        }
    }

    // MARK: - Apple Login
    @IBAction func appleTapped(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Guest Login
    @IBAction func guestTapped(_ sender: UIButton) {
        saveLogin(name: "Guest")
        goToOnboarding()
    }

    // MARK: - Save Login Info
    // saving login state and name to userdefaults
    // member since year is only set once — never overwritten
    private func saveLogin(name: String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(name, forKey: "userName")

        if UserDefaults.standard.integer(forKey: "member_since_year") == 0 {
            let year = Calendar.current.component(.year, from: Date())
            UserDefaults.standard.set(year, forKey: "member_since_year")
        }
    }

    // MARK: - Go To Onboarding
    // replacing root view controller so user cant go back to login
    private func goToOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let dobVC = storyboard.instantiateViewController(
            withIdentifier: "OnboardingDOBViewController"
        ) as? OnboardingDOBViewController else {
            print("dob view controller not found in storyboard")
            return
        }

        dobVC.dataModel = DataModel()

        let nav = UINavigationController(rootViewController: dobVC)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - Apple Sign In Delegate
extension LoginViewController: ASAuthorizationControllerDelegate,
                                ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // apple only gives full name on very first sign in
            // after that it comes back empty so we preserve whatever was saved before
            let given  = credential.fullName?.givenName ?? ""
            let family = credential.fullName?.familyName ?? ""
            let fullName = [given, family].filter { !$0.isEmpty }.joined(separator: " ")

            let existing = UserDefaults.standard.string(forKey: "userName") ?? ""
            let name = fullName.isEmpty ? (existing.isEmpty ? "User" : existing) : fullName

            saveLogin(name: name)
            goToOnboarding()
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("apple sign in failed:", error.localizedDescription)
    }
}
