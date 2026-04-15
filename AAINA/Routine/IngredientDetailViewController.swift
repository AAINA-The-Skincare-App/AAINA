import UIKit

class IngredientDetailViewController: UIViewController {

    let ingredient: Ingredient
    private let ui = IngredientDetailUI()

    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        self.additionalSafeAreaInsets.bottom = 10
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.applyAINABackground()

        ui.build(in: view, ingredient: ingredient)

        ui.closeButton.addTarget(self,
                                 action: #selector(close),
                                 for: .touchUpInside)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
