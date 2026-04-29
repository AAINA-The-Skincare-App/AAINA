import UIKit

class MainTabBarViewController: UITabBarController {

    var dataModel: AppDataModel!
    private var profileNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if dataModel == nil {
            dataModel = AppDataModel.shared
        }

        overrideUserInterfaceStyle = .light
        configureTabs()
        removeProfileTab()
        injectDataModelToHome()
    }

    func openProfileFromHome() {
        guard let profileNavigationController,
              profileNavigationController.presentingViewController == nil
        else { return }

        profileNavigationController.modalPresentationStyle = .fullScreen
        profileNavigationController.overrideUserInterfaceStyle = .light
        profileNavigationController.viewControllers.first?.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissProfile)
        )

        selectedViewController?.present(profileNavigationController, animated: true)
    }

    @objc private func dismissProfile() {
        profileNavigationController?.dismiss(animated: true)
    }

    private func configureTabs() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.96)

        let selectedColor = UIColor.ainaCoralPink
        let normalColor = UIColor.ainaTextSecondary
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = normalColor

        viewControllers?.enumerated().forEach { index, controller in
            switch index {
            case 0:
                controller.tabBarItem.title = "HOME"
                controller.tabBarItem.image = UIImage(systemName: "house")
                controller.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
            case 1:
                controller.tabBarItem.title = "ROUTINE"
                controller.tabBarItem.image = UIImage(systemName: "list.bullet.clipboard")
                controller.tabBarItem.selectedImage = UIImage(systemName: "list.bullet.clipboard.fill")
            case 2:
                controller.tabBarItem.title = "JOURNAL"
                controller.tabBarItem.image = UIImage(systemName: "book.pages")
                controller.tabBarItem.selectedImage = UIImage(systemName: "book.pages.fill")
            default:
                break
            }
        }
    }

    private func removeProfileTab() {
        guard let controllers = viewControllers else { return }

        profileNavigationController = controllers.compactMap { $0 as? UINavigationController }.first {
            $0.viewControllers.first is ProfileViewController
        }

        viewControllers = controllers.filter { controller in
            guard let nav = controller as? UINavigationController else { return true }
            return !(nav.viewControllers.first is ProfileViewController)
        }
    }

    private func injectDataModelToHome() {
        guard let viewControllers = viewControllers else { return }

        for controller in viewControllers {

            if let nav = controller as? UINavigationController,
               let homeVC = nav.topViewController as? HomeViewController {
                homeVC.dataModel = dataModel
            } else if let homeVC = controller as? HomeViewController {
                homeVC.dataModel = dataModel
            }
        }
    }
}
