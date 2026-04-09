import UIKit

class MainTabBarViewController: UITabBarController {

    var dataModel: AppDataModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if dataModel == nil {
            dataModel = AppDataModel.shared
        }

        injectDataModelToHome()
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
