//
//  OnboardingResultMornRoutineCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class OnboardingResultRoutineCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
    }
    
    // The system calls this during self-sizing. Returning a preference with the
    // fitted height tells Compositional Layout to size the cell to its content.
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        // Let Auto Layout calculate the height based on the fixed width
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        layoutAttributes.frame.size.height = fittedSize.height
        return layoutAttributes
    }
    
    // MARK: - Setup UI
    
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
        cardView.layer.masksToBounds = false
        
        // Title
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .systemGray
        
        // Stack spacing
        stackView.spacing = 0
    }
    
    // MARK: - Configure
    
    func configure(title: String, steps: [AIRoutineStep]) {
        titleLabel.text = title
        
        // Clear previous views (important for reuse)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, step) in steps.enumerated() {
            let stepView = createStepView(step: step)
            stackView.addArrangedSubview(stepView)
            
            if index < steps.count - 1 {
                stackView.addArrangedSubview(createDivider())
            }
        }
    }
    
    // MARK: - Step View
    
    private func createStepView(step: AIRoutineStep) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 14
        hStack.alignment = .top
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Badge
        let badge = UILabel()
        badge.text = "\(step.stepNumber)"
        badge.textAlignment = .center
        badge.font = .systemFont(ofSize: 14, weight: .medium)
        badge.backgroundColor = .ainaCoralPink
        badge.textColor = .white
        badge.layer.cornerRadius = 14
        badge.clipsToBounds = true
        badge.setContentHuggingPriority(.required, for: .horizontal)
        badge.setContentCompressionResistancePriority(.required, for: .horizontal)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 28),
            badge.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        // Text stack
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = step.productName
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = step.keyIngredients.joined(separator: " · ")
        ingredientsLabel.font = .systemFont(ofSize: 13)
        ingredientsLabel.textColor = .ainaCoralPink
        ingredientsLabel.numberOfLines = 0
        // Hide if empty so it doesn't add extra vertical space
        ingredientsLabel.isHidden = step.keyIngredients.isEmpty
        
        let reasonLabel = UILabel()
        reasonLabel.text = step.reason
        reasonLabel.font = .systemFont(ofSize: 13)
        reasonLabel.textColor = .secondaryLabel
        reasonLabel.numberOfLines = 0
        reasonLabel.isHidden = step.reason.isEmpty
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(ingredientsLabel)
        textStack.addArrangedSubview(reasonLabel)
        
        hStack.addArrangedSubview(badge)
        hStack.addArrangedSubview(textStack)
        container.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
        
        return container
    }
    
    // MARK: - Divider
    
    private func createDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        return view
    }
}
