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

            override func awakeFromNib() {
                
                super.awakeFromNib()
                setupUI()
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

            override func prepareForReuse() {
                super.prepareForReuse()

              
                updateCheckboxUI()

                ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
        }

        // MARK: - UI Setup

        extension StepCollectionViewCell {

            private func setupUI() {

                backgroundColor = .clear
                contentView.backgroundColor = .clear

                // Card
                cardView.backgroundColor = .systemBackground
                cardView.layer.cornerRadius = 24
                cardView.layer.cornerCurve = .continuous

                cardView.layer.shadowColor = UIColor.black.cgColor
                cardView.layer.shadowOpacity = 0.06
                cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
                cardView.layer.shadowRadius = 20

                // Stack
                ingredientsStackView.axis = .vertical
                ingredientsStackView.spacing = 12

                // Checkbox
                var config = UIButton.Configuration.plain()
                config.image = UIImage(systemName: "circle")
                config.preferredSymbolConfigurationForImage =
                    UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)

                checkButton.configuration = config
                checkButton.tintColor = .systemGray3
                checkButton.adjustsImageWhenHighlighted = false

                checkButton.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
            }
        }

        // MARK: - Configure

        extension StepCollectionViewCell {

            func configure(step: RoutineStep, ingredients: [String], isChecked: Bool) {

                stepTitleLabel.text = "Step \(step.stepOrder) : \(step.type.rawValue.capitalized)"
                productNameLabel.text = step.stepTitle

                keyIngredientsTitleLabel.text = "Key Ingredients"
                keyIngredientsTitleLabel.textColor = .secondaryLabel
                keyIngredientsTitleLabel.font = .systemFont(ofSize: 13, weight: .medium)

                self.ingredients = Array(ingredients.prefix(4))
                self.isChecked = isChecked

                updateCheckboxUI()
                buildIngredientsGrid()
            }

            func configure(aiStep: AIRoutineStep, isChecked: Bool) {

                stepTitleLabel.text = "Step \(aiStep.stepNumber) : \(aiStep.productType.rawValue.capitalized)"
                productNameLabel.text = aiStep.productName

                keyIngredientsTitleLabel.text = "Key Ingredients"
                keyIngredientsTitleLabel.textColor = .secondaryLabel
                keyIngredientsTitleLabel.font = .systemFont(ofSize: 13, weight: .medium)

                self.ingredients = Array(aiStep.keyIngredients.prefix(4))
                self.isChecked = isChecked

                updateCheckboxUI()
                buildIngredientsGrid()
            }
        }

        // MARK: - Checkbox

    // MARK: - Checkbox

    extension StepCollectionViewCell {

        @objc private func toggleCheck() {
            isChecked.toggle()

            UIView.animate(withDuration: 0.15, animations: {
                self.checkButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.checkButton.transform = .identity
                }
            }

            updateCheckboxUI()
            checkChanged?(isChecked)
        }

        private func updateCheckboxUI() {

            var config = checkButton.configuration

            if isChecked {
                config?.image = UIImage(systemName: "checkmark.circle.fill")
                checkButton.tintColor = .systemBlue
            } else {
                config?.image = UIImage(systemName: "circle")
                checkButton.tintColor = .systemGray3
                checkButton.backgroundColor = .systemBackground
                
            }

            checkButton.configuration = config
        }
    }
        // MARK: - Ingredients Grid

        extension StepCollectionViewCell {

            private func buildIngredientsGrid() {

                ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

                var row: UIStackView?

                for (index, ingredient) in ingredients.enumerated() {

                    if index % 2 == 0 {
                        row = UIStackView()
                        row!.axis = .horizontal
                        row!.spacing = 12
                        row!.distribution = .fillEqually
                        ingredientsStackView.addArrangedSubview(row!)
                    }

                    row?.addArrangedSubview(createPill(title: ingredient))
                }

                if ingredients.count % 2 != 0 {
                    row?.addArrangedSubview(UIView())
                }
            }

            private func createPill(title: String) -> PaddingLabel {

                let pill = PaddingLabel()
                pill.text = title
                pill.textAlignment = .center
                pill.font = .systemFont(ofSize: 14, weight: .medium)

                pill.textColor = UIColor.label.withAlphaComponent(0.85)
                pill.backgroundColor = .systemGray5

                pill.layer.cornerRadius = 14
                pill.layer.masksToBounds = true

                pill.padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

                return pill
            }
        }

        // MARK: - Actions

        extension StepCollectionViewCell {

            @IBAction func arrowPressed(_ sender: UIButton) {
                arrowTapped?()
            }
        }
