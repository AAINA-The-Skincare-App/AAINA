//
//  RoutineCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 07/02/26.
//

import UIKit

class RoutineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    
    private var completion: [String: Bool] = [:]
    private var totalSteps: Int = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 22
        containerView.backgroundColor = .white
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: 12,
            left: 20,
            bottom: 12,
            right: 20
        )
        stackView.spacing = 10
        
        progressView.progress = 0
        subtitleLabel.text = "completed"
        
        // Chevron styling
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
    private func buildRow(_ step: RoutineStep) -> UIView {
        
        let row = UIView()
        
        let label = UILabel()
        label.text = step.stepTitle
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        button.setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
        
        updateButton(button, done: false)
        
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                
                let newState = !(self.completion[step.id] ?? false)
                self.completion[step.id] = newState
                
                self.updateButton(button, done: newState)
                self.updateProgressUI()
            },
            for: .touchUpInside
        )
        
        row.addSubview(label)
        row.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 4),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -4),
            button.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            row.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return row
    }
    
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
        let imageName = done ? "checkmark.circle.fill" : "circle"
        button.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        contentView.layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: targetSize.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size
    }
}
