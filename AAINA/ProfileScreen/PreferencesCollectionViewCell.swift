import UIKit

class PreferencesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var languageIcon: UIImageView!
    @IBOutlet weak var languageTitle: UILabel!
    @IBOutlet weak var languageSubtitle: UILabel!
    
    @IBOutlet weak var notificationsIcon: UIImageView!
    @IBOutlet weak var notificationsTitle: UILabel!
    @IBOutlet weak var notificationsToggle: UISwitch!

    // Callbacks
    var onLanguageTapped: (() -> Void)?
    var onNotificationsChanged: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupData()
        setupGestures()   // FIXED NAME
    }

    private func setupUI() {
        containerView.backgroundColor = .ainaGlassSurface
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
    }

    private func setupData() {
        languageIcon.image = UIImage(systemName: "globe")
        languageIcon.tintColor = .ainaCoralPink
        languageTitle.text = "Language"
        languageSubtitle.text = SettingsManager.shared.selectedLanguage
        languageSubtitle.textColor = .systemGray

        notificationsIcon.image = UIImage(systemName: "bell")
        notificationsIcon.tintColor = .ainaCoralPink
        notificationsTitle.text = "Notifications"

        notificationsToggle.onTintColor = .ainaCoralPink
        notificationsToggle.isOn = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }

    // FIXED GESTURE (NO row1Stack needed)
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(languageTapped))
        languageTitle.isUserInteractionEnabled = true
        languageTitle.addGestureRecognizer(tap)
    }

    @objc private func languageTapped() {
        onLanguageTapped?()
    }

    @IBAction func notificationsToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notifications_enabled")
        onNotificationsChanged?(sender.isOn)
    }
}
