//
//  HomeRoutineSectionCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 28/03/26.
//

import UIKit

class HomeRoutineSectionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeRoutineSectionCollectionViewCell"
    
    private var steps: [String] = []
    private var completedStates: [Bool] = []
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 24
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .clear

        containerView.applyGlass(cornerRadius: 24)

//        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
//        containerView.layer.shadowOpacity = 0.10
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
//        containerView.layer.shadowRadius = 20
        containerView.layer.masksToBounds = false

        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        stepsLabel.textColor = .black
        stepsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        completedLabel.textColor = .gray
        completedLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        if let sublayers = progressView.layer.sublayers, sublayers.count > 1 {
            sublayers[1].cornerRadius = 4
            sublayers[1].masksToBounds = true
        }
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
    }
    
    // MARK: - CONFIGURE
    
    func configure(steps: [String], completedCount: Int) {
        self.steps = steps
        
        // Initialize states
        completedStates = steps.enumerated().map { index, _ in
            index < completedCount
        }
        
        updateUI()
        reloadSteps()
    }
    
    // MARK: - UI UPDATE
    
    private func updateUI() {
        let completedCount = completedStates.filter { $0 }.count
        let totalCount = steps.count
        
        stepsLabel.text = "\(completedCount)/\(totalCount) Steps"
        completedLabel.text = "completed"
        
        let progress = totalCount == 0 ? 0 : Float(completedCount) / Float(totalCount)
        progressView.setProgress(progress, animated: true)
    }
    
    private func reloadSteps() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for (index, step) in steps.enumerated() {
            let row = makeStepRow(title: step, index: index)
            stackView.addArrangedSubview(row)
        }
    }
    
    // MARK: - ROW
    
    private func makeStepRow(title: String, index: Int) -> UIView {
        
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.tag = index
        
        updateButtonUI(button, isCompleted: completedStates[index])
        
        button.addTarget(self, action: #selector(stepTapped(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        rowView.addSubview(button)
        rowView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 28),
            
            button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            button.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
        ])
        
        return rowView
    }
    
    // MARK: - BUTTON UI
    
    private func updateButtonUI(_ button: UIButton, isCompleted: Bool) {
        if isCompleted {
            button.backgroundColor = .systemBlue
            button.setImage(UIImage(systemName: "checkmark"), for: .normal)
            button.tintColor = .white
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray5.cgColor
            button.setImage(nil, for: .normal)
        }
    }
    
    // MARK: - ACTION
    
    @objc private func stepTapped(_ sender: UIButton) {
        let index = sender.tag
        
        completedStates[index].toggle()
        
        updateButtonUI(sender, isCompleted: completedStates[index])
        updateUI()
    }
}
