import UIKit

class StepCollectionViewCell: UICollectionViewCell {

    static let identifier = "StepCollectionViewCell"

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var stepTitleLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!

    @IBOutlet weak var keyIngredientsTitleLabel: UILabel!
    @IBOutlet weak var ingredientsStackView: UIStackView!

    @IBOutlet weak var arrowButton: UIButton!
  
  
        var arrowTapped: (() -> Void)?
        var checkChanged: ((Bool) -> Void)?

        private var isChecked = false
        private var ingredients: [String] = []
    private let checkGradient = CAGradientLayer()

        private let cardLayer = CAGradientLayer()

        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
    override func layoutSubviews() {
        super.layoutSubviews()

        cardLayer.frame = cardView.bounds
        checkGradient.frame = checkButton.bounds

        // ✅ MAKE IT PERFECT CIRCLE
        let radius = checkButton.bounds.height / 2
        checkButton.layer.cornerRadius = radius
       
    }
        override func prepareForReuse() {
            super.prepareForReuse()
            updateCheckboxUI()
            ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }

        override func preferredLayoutAttributesFitting(
            _ layoutAttributes: UICollectionViewLayoutAttributes
        ) -> UICollectionViewLayoutAttributes {

            let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
            let width = attributes.frame.width

            let size = contentView.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

            attributes.frame.size = CGSize(width: width, height: ceil(size.height))
            return attributes
        }
    }

    // MARK: - UI Setup


extension StepCollectionViewCell {

    // MARK: - UI SETUP

    private func setupUI() {
        // 🔥 ADD THIS (YOU MISSED THIS)

        checkGradient.colors = [
            UIColor(red: 255/255, green: 120/255, blue: 140/255, alpha: 1).cgColor,
            UIColor(red: 232/255, green: 154/255, blue: 160/255, alpha: 1).cgColor
        ]

        checkGradient.startPoint = CGPoint(x: 0, y: 0)
        checkGradient.endPoint = CGPoint(x: 1, y: 1)
        checkGradient.cornerRadius = 16

        checkButton.layer.insertSublayer(checkGradient, at: 0)

        // initially hidden
        checkGradient.isHidden = true

      
       

        // 🔥 IMPORTANT
        contentView.layer.masksToBounds = false
        checkButton.adjustsImageWhenHighlighted = false
        checkButton.adjustsImageWhenDisabled = false
        checkButton.showsTouchWhenHighlighted = false
     
        cardView.clipsToBounds = false
        contentView.clipsToBounds = false
        self.clipsToBounds = false
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.white.cgColor

        // ✨ soft white glow
     //   cardView.layer.shadowColor = UIColor.white.cgColor
      //  cardView.layer.shadowOpacity = 1
       // cardView.layer.shadowRadius = 8
       // cardView.layer.shadowOffset = .zero

       
        checkButton.layer.masksToBounds = false
        

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 6)

        // MARK: TEXT

        stepTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        stepTitleLabel.textColor = UIColor.ainaTextPrimary

        productNameLabel.font = .systemFont(ofSize: 15, weight: .regular)
        productNameLabel.textColor = UIColor.ainaTextPrimary   // 🔥 now black
        keyIngredientsTitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        keyIngredientsTitleLabel.textColor = UIColor(
            red: 150/255,
            green: 150/255,
            blue: 165/255,
            alpha: 1
        )
        keyIngredientsTitleLabel.text = "Key Ingredients".uppercased()
        // MARK: STACK (🔥 IMPORTANT)

        ingredientsStackView.axis = .vertical
        ingredientsStackView.spacing = 10

        // MARK: CHECK BUTTON

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "circle")
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)

       
        checkButton.tintColor = .systemGray3
        checkButton.backgroundColor = .clear
        checkButton.layer.masksToBounds = false
        checkButton.adjustsImageWhenHighlighted = false

        checkButton.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
    }
}

///////////////////////////////////////////////////////////////

extension StepCollectionViewCell {

    // MARK: - CONFIGURE

    func configure(step: RoutineStep, ingredients: [String], isChecked: Bool) {

        stepTitleLabel.text = "Step \(step.stepOrder) : \(step.type.rawValue.capitalized)"
        productNameLabel.text = step.stepTitle

        keyIngredientsTitleLabel.text = "Key Ingredients".uppercased()
        keyIngredientsTitleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        keyIngredientsTitleLabel.textColor = UIColor(
            red: 150/255,
            green: 150/255,
            blue: 165/255,
            alpha: 1
        )

        self.ingredients = Array(ingredients.prefix(4)) // max 4 for grid
        self.isChecked = isChecked

        updateCheckboxUI()
        buildIngredientsGrid()
    }

    func configure(aiStep: AIRoutineStep, isChecked: Bool) {

        stepTitleLabel.text = "Step \(aiStep.stepNumber) : \(aiStep.productType.rawValue.capitalized)"
        productNameLabel.text = aiStep.productName
        keyIngredientsTitleLabel.text = "Key Ingredients".uppercased()
        self.ingredients = Array(aiStep.keyIngredients.prefix(4))
        self.isChecked = isChecked

        updateCheckboxUI()
        buildIngredientsGrid()
    }
}

///////////////////////////////////////////////////////////////

extension StepCollectionViewCell {
    
    // MARK: - CHECKBOX
    
    @objc private func toggleCheck() {
        isChecked.toggle()
        UIView.performWithoutAnimation {
            self.checkButton.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.15,
                       animations: {
            self.checkButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.checkButton.transform = .identity
            }
        }
        updateCheckboxUI()
        checkChanged?(isChecked)
    }
    private func updateCheckboxUI() {
        
        if isChecked {
            
            // ✅ SOLID SYSTEM PINK
            checkButton.backgroundColor = UIColor.systemPink.withAlphaComponent(0.3)
            
            // ✅ CHECKMARK
            checkButton.setImage(
                UIImage(systemName: "checkmark")?
                    .withConfiguration(
                        UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
                    ),
                for: .normal
            )
            
            checkButton.tintColor = .white
            
            // ✨ GLOW (SOFT + PREMIUM)
            checkButton.layer.shadowColor = UIColor.systemPink.cgColor
            checkButton.layer.shadowOpacity = 0.6
            checkButton.layer.shadowRadius = 10
            checkButton.layer.shadowOffset = .zero
            
            // 💫 subtle scale
            checkButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            
        } else {
            
            // ❌ RESET
            checkButton.backgroundColor = .clear
            
            checkButton.setImage(
                UIImage(systemName: "circle"),
                for: .normal
            )
            
            checkButton.tintColor = UIColor.systemGray3
            checkButton.layer.shadowOpacity = 0
            checkButton.transform = .identity
        }
    }
}
///////////////////////////////////////////////////////////////

extension StepCollectionViewCell {

    // MARK: - GRID (🔥 MAIN FIX)

    private func buildIngredientsGrid() {

        ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var rowStack: UIStackView?

        for (index, ingredient) in ingredients.enumerated() {

            if index % 2 == 0 {
                rowStack = UIStackView()
                rowStack?.axis = .horizontal
                rowStack?.spacing = 10
                rowStack?.distribution = .fillEqually
                ingredientsStackView.addArrangedSubview(rowStack!)
            }

            let pill = createPill(title: ingredient)
            rowStack?.addArrangedSubview(pill)
        }

        // fill empty space if odd count
        if ingredients.count % 2 != 0 {
            rowStack?.addArrangedSubview(UIView())
        }
    }

    // MARK: - PILL (🔥 EXACT INSPO)

    private func createPill(title: String) -> PaddingLabel {

        let pill = PaddingLabel()
        pill.text = title
        pill.textAlignment = .center
        pill.font = .systemFont(ofSize: 14, weight: .medium)

        // 🎯 EXACT LIGHT GREY
        pill.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)

        pill.textColor = UIColor.ainaTextPrimary

        // 💊 SHAPE
        pill.layer.cornerRadius = 16
        pill.layer.cornerCurve = .continuous
        pill.layer.masksToBounds = true
        pill.layer.borderColor = UIColor.white.cgColor

        pill.padding = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

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
