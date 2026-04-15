import UIKit

struct AppLanguage {
    let code: String       
    let localName: String  // shown in its own script
    let englishName: String
    let flag: String
}

class LanguagePickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var onLanguageSelected: ((AppLanguage) -> Void)?

    private let languages: [AppLanguage] = [
        AppLanguage(code: "en", localName: "English",   englishName: "English", flag: "🇺🇸"),
        AppLanguage(code: "hi", localName: "हिन्दी",    englishName: "Hindi",   flag: "🇮🇳"),
    ]

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Language"
        view.applyAINABackground()

        navigationItem.largeTitleDisplayMode = .never

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LangCell")

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Info footer
        let footer = UILabel()
        footer.text = "Changing the language restarts the app interface."
        footer.font = UIFont.systemFont(ofSize: 13)
        footer.textColor = .systemGray
        footer.textAlignment = .center
        footer.numberOfLines = 2
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        tableView.tableFooterView = footer
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell", for: indexPath)
        let lang = languages[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = "\(lang.flag)  \(lang.localName)"
        config.secondaryText = lang.englishName
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
        config.secondaryTextProperties.color = .systemGray
        cell.contentConfiguration = config
        cell.backgroundColor = .clear

        // Checkmark on currently selected language
        let selected = SettingsManager.shared.selectedLanguage
        cell.accessoryType = (selected == lang.englishName) ? .checkmark : .none
        cell.tintColor = .systemPink

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Languages"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let lang = languages[indexPath.row]

        // No change
        if SettingsManager.shared.selectedLanguage == lang.englishName { return }

        // Save selection
        SettingsManager.shared.selectedLanguage = lang.englishName
        SettingsManager.shared.selectedLanguageCode = lang.code
        tableView.reloadData()

        // Notify parent
        onLanguageSelected?(lang)

        // Apply language & reload root UI
        applyLanguageAndReload(lang)
    }

    // MARK: - Apply

    private func applyLanguageAndReload(_ lang: AppLanguage) {
        // iOS language override via UserDefaults (takes effect on next launch normally,
        // but we force-reload the root VC to apply it in-session too)
        UserDefaults.standard.set([lang.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        let alert = UIAlertController(
            title: lang.localName,
            message: "Language updated to \(lang.englishName). The interface will reload now.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.reloadAppInterface()
        })
        present(alert, animated: true)
    }

    private func reloadAppInterface() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        // Re-build the root view controller so label strings pick up the new locale
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let newRoot: UIViewController
        if UserProfile.load() != nil {
            guard let tabBar = storyboard.instantiateViewController(
                withIdentifier: "MainTabBarViewController"
            ) as? MainTabBarViewController else { return }
            tabBar.dataModel = DataModel()
            newRoot = tabBar
        } else {
            guard let nav = storyboard.instantiateInitialViewController() else { return }
            newRoot = nav
        }

        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
            window.rootViewController = newRoot
        }
    }
}
