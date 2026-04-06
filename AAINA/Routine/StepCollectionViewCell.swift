import UIKit

class StepCollectionViewCell: UICollectionViewCell {

    static let identifier = "StepCollectionViewCell"

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var StepNumber: UILabel!
    @IBOutlet weak var stepTitleLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var keyIngredientsTitleLabel: UILabel!
    @IBOutlet weak var ingredientsStackView: UIStackView!

    @IBOutlet weak var arrowButton: UIButton!
  
    var arrowTapped: (() -> Void)?
        var checkChanged: ((Bool) -> Void)?
     
        // MARK: - State
        private var isChecked = false
        private var ingredients: [String] = []
     
        // MARK: - Lifecycle
     
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
     
        override func layoutSubviews() {
            super.layoutSubviews()
            checkButton.layer.cornerRadius = checkButton.bounds.height / 2
        }
     
        override func prepareForReuse() {
            super.prepareForReuse()
            updateCheckboxUI(animated: false)
            ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
     
        override func preferredLayoutAttributesFitting(
            _ layoutAttributes: UICollectionViewLayoutAttributes
        ) -> UICollectionViewLayoutAttributes {
            let attrs = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
            let size = contentView.systemLayoutSizeFitting(
                CGSize(width: attrs.frame.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            attrs.frame.size = CGSize(width: attrs.frame.width, height: ceil(size.height))
            return attrs
        }
    }
     
    // MARK: - UI Setup
     
    extension StepCollectionViewCell {
     
        private func setupUI() {
            arrowButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.layer.masksToBounds = false
     
            // Card — clean white surface
            cardView.backgroundColor = UIColor.white.withAlphaComponent(0.88)
            cardView.layer.cornerRadius = 24
            cardView.layer.cornerCurve = .continuous
            cardView.layer.masksToBounds = false
            cardView.layer.borderWidth = 0
            cardView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.07
            cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
            cardView.layer.shadowRadius = 18
     
            // "STEP 01" — small muted uppercase
            StepNumber.font = .systemFont(ofSize: 11, weight: .semibold)
            StepNumber.textColor = UIColor(red: 160/255, green: 155/255, blue: 175/255, alpha: 1)
     
            // "Cleanser" — large bold title
            stepTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
            stepTitleLabel.textColor = UIColor(red: 28/255, green: 22/255, blue: 48/255, alpha: 1)
     
            // "Gentle Hydrating Cleanser" — muted subtitle
            productNameLabel.font = .systemFont(ofSize: 11, weight: .regular)
            productNameLabel.textColor = UIColor(red: 100/255, green: 95/255, blue: 115/255, alpha: 3)
            productNameLabel.numberOfLines = 1
     
            // Separator
            separatorView.backgroundColor = UIColor.black.withAlphaComponent(0.06)
     
            // "KEY INGREDIENTS"
            keyIngredientsTitleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            keyIngredientsTitleLabel.textColor = UIColor(red: 160/255, green: 155/255, blue: 175/255, alpha: 1)
            keyIngredientsTitleLabel.text = "KEY INGREDIENTS"
     
            // Ingredients stack
            ingredientsStackView.axis = .vertical
            ingredientsStackView.spacing = 8
     
            // Arrow
            arrowButton.tintColor = UIColor(red: 190/255, green: 185/255, blue: 200/255, alpha: 1)
     
            // Checkbox
            checkButton.backgroundColor = .clear
            checkButton.layer.masksToBounds = false
            checkButton.adjustsImageWhenHighlighted = false
            checkButton.adjustsImageWhenDisabled = false
            checkButton.showsTouchWhenHighlighted = false
            checkButton.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
     
            updateCheckboxUI(animated: false)
        }
    }
     
    // MARK: - Configure
     
    extension StepCollectionViewCell {
     
        func configure(step: RoutineStep, ingredients: [String], isChecked: Bool) {
            StepNumber.text       = String(format: "STEP %02d", step.stepOrder)  // "STEP 01"
            stepTitleLabel.text   = step.type.rawValue.capitalized               // "Cleanser"
            productNameLabel.text = step.stepTitle                               // "Gentle Hydrating Cleanser"
     
            self.ingredients = Array(ingredients.prefix(4))
            self.isChecked = isChecked
            updateCheckboxUI(animated: false)
            buildIngredientsGrid()
        }
     
        func configure(aiStep: AIRoutineStep, isChecked: Bool) {
            StepNumber.text       = String(format: "STEP %02d", aiStep.stepNumber)  // "STEP 01"
            stepTitleLabel.text   = aiStep.productType.rawValue.capitalized          // "Cleanser"
            productNameLabel.text = aiStep.productName                               // "Gentle Hydrating Cleanser"
     
            self.ingredients = Array(aiStep.keyIngredients.prefix(4))
            self.isChecked = isChecked
            updateCheckboxUI(animated: false)
            buildIngredientsGrid()
        }
    }
     
    // MARK: - Checkbox
     
    extension StepCollectionViewCell {
     
        @objc private func toggleCheck() {
            isChecked.toggle()
     
            UIView.animate(withDuration: 0.12, animations: {
                self.checkButton.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
            }) { _ in
                UIView.animate(
                    withDuration: 0.25, delay: 0,
                    usingSpringWithDamping: 0.45,
                    initialSpringVelocity: 7,
                    options: [],
                    animations: { self.checkButton.transform = .identity }
                )
            }
     
            updateCheckboxUI(animated: true)
            checkChanged?(isChecked)
        }
     
        private func updateCheckboxUI(animated: Bool) {
            let apply = {
                if self.isChecked {
                    self.checkButton.backgroundColor = UIColor(
                        red: 232/255, green: 90/255, blue: 120/255, alpha: 1
                    )
                    self.checkButton.setImage(
                        UIImage(systemName: "checkmark")?
                            .withConfiguration(
                                UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
                            ),
                        for: .normal
                    )
                    self.checkButton.tintColor = .white
                    self.checkButton.layer.shadowColor = UIColor(
                        red: 232/255, green: 90/255, blue: 120/255, alpha: 1
                    ).cgColor
                    self.checkButton.layer.shadowOpacity = 0.45
                    self.checkButton.layer.shadowRadius  = 10
                    self.checkButton.layer.shadowOffset  = .zero
     
                } else {
                    self.checkButton.backgroundColor = .clear
                    self.checkButton.setImage(
                        UIImage(systemName: "circle")?
                            .withConfiguration(
                                UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
                            ),
                        for: .normal
                    )
                    self.checkButton.tintColor = UIColor(
                        red: 200/255, green: 195/255, blue: 210/255, alpha: 1
                    )
                    self.checkButton.layer.shadowOpacity = 0
                }
            }
     
            animated ? UIView.animate(withDuration: 0.2, animations: apply) : apply()
        }
    }
     
    // MARK: - Ingredients Grid
     
    extension StepCollectionViewCell {
     
        private func buildIngredientsGrid() {
            ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
     
            var rowStack: UIStackView?
            for (index, ingredient) in ingredients.enumerated() {
                if index % 2 == 0 {
                    rowStack = UIStackView()
                    rowStack?.axis = .horizontal
                    rowStack?.spacing = 8
                    rowStack?.distribution = .fillEqually
                    ingredientsStackView.addArrangedSubview(rowStack!)
                }
                rowStack?.addArrangedSubview(makePill(title: ingredient))
            }
     
            if ingredients.count % 2 != 0 {
                rowStack?.addArrangedSubview(UIView())
            }
        }
     
        private func makePill(title: String) -> PaddingLabel {
            let pill = PaddingLabel()
            pill.text = title
            pill.textAlignment = .center
            pill.font = .systemFont(ofSize: 13, weight: .medium)
            pill.textColor = UIColor(red: 50/255, green: 45/255, blue: 65/255, alpha: 1)
            pill.backgroundColor = .white
            pill.layer.cornerRadius = 14
            pill.layer.cornerCurve = .continuous
            pill.layer.masksToBounds = true
            pill.layer.borderWidth = 0.5
            pill.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
            pill.padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            return pill
        }
    }
     
///////////////////////////////////////////////////////////////

extension StepCollectionViewCell {

    // MARK: - ACTION

    @IBAction func arrowPressed(_ sender: UIButton) {
        arrowTapped?()
    }
}
