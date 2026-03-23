//
//  RoutineCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 07/02/26.
//

import UIKit

class RoutineCollectionViewCell: UICollectionViewCell {
    
    private var completion: [String: Bool] = [:]
    private var totalSteps: Int = 0
    
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24
        containerView.layer.cornerCurve = .continuous
        
        // StackView spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.spacing = 12
        
        // Progress bar styling
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor.systemBlue
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
        
        progressView.progress = 0
        subtitleLabel.text = "completed"
        
        // Chevron
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        chevronImageView.preferredSymbolConfiguration = config
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        completion.removeAll()
        totalSteps = 0
        
        progressView.progress = 0
        stepsLabel.text = "0/0 Steps"
    }
    
    func configure(with steps: [RoutineStep]) {
        totalSteps = steps.count
        
        for step in steps {
            completion[step.id] = false
            let row = buildRow(step)
            stackView.addArrangedSubview(row)
        }
        
        updateProgressUI()
    }
    
    // MARK: - Row UI
    
    private func buildRow(_ step: RoutineStep) -> UIView {
        
        let row = UIView()
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        button.setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
        
        updateButton(button, done: false)
        
        let label = UILabel()
        label.text = step.stepTitle
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Toggle action
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                
                let newState = !(self.completion[step.id] ?? false)
                self.completion[step.id] = newState
                
                UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve) {
                    self.updateButton(button, done: newState)
                }
                
                self.updateProgressUI()
            },
            for: .touchUpInside
        )
        
        row.addSubview(button)
        row.addSubview(label)
        
        NSLayoutConstraint.activate([
            
            button.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            button.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28),
            
            label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            label.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
            
            row.heightAnchor.constraint(equalToConstant: 44)
        ])
        return row
    }
    
    // MARK: - UI Updates
    
    private func updateProgressUI() {
        
        let completed = completion.values.filter { $0 }.count
        stepsLabel.text = "\(completed)/\(totalSteps) Steps"
        
        let progress: Float =
            totalSteps == 0 ? 0 : Float(completed) / Float(totalSteps)
        
        UIView.animate(withDuration: 0.25) {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    private func updateButton(_ button: UIButton, done: Bool) {
        
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        
        if done {
            let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .systemBlue
        } else {
            let image = UIImage(systemName: "circle", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .systemGray3
        }
    }
    
    // MARK: - Dynamic Height
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        contentView.layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: targetSize.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return size
    }
}
