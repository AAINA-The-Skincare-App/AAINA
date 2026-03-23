//
//  InsightsCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 10/02/26.
//

import UIKit

class InsightsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartIcon: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overallSkinHealthLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var basedLabel: UILabel!
    
    
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyGradient()
    }
    
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        chartIcon.layer.shadowColor = UIColor.black.cgColor
        chartIcon.layer.shadowOpacity = 0.15
        chartIcon.layer.shadowOffset = CGSize(width: 0, height: 4)
        chartIcon.layer.shadowRadius = 8
        chartIcon.layer.masksToBounds = false

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24
        containerView.layer.cornerCurve = .continuous
        
        // Title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        // Left section
        overallSkinHealthLabel.text = "Overall Skin Health"
        overallSkinHealthLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        lowLabel.text = "Low"
        highLabel.text = "High"
        lowLabel.textColor = .secondaryLabel
        highLabel.textColor = .secondaryLabel
        
        basedLabel.textColor = .secondaryLabel
        basedLabel.font = .systemFont(ofSize: 13)
        
        // Progress bar base
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = .clear
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        // Make it slightly thicker (like Figma)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.8)
    }
    
    // MARK: - Configure
    
    func configure(title: String,
                   progress: Float,
                   routinePercent: Int,
                   description: String) {
        
        titleLabel.text = title
        basedLabel.text = description
        
        progressView.setProgress(progress, animated: false)
        
        // Refresh gradient after setting progress
        applyGradient()
    }
    
    // MARK: - Gradient Progress
    
    private func applyGradient() {
        
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemYellow.cgColor,
            UIColor.systemGreen.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = progressView.bounds
        gradient.cornerRadius = progressView.layer.cornerRadius
        
        let progressWidth = progressView.bounds.width * CGFloat(progressView.progress)
        
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: progressWidth,
            height: progressView.bounds.height
        )
        maskLayer.backgroundColor = UIColor.black.cgColor
        
        gradient.mask = maskLayer
        
        progressView.layer.addSublayer(gradient)
        gradientLayer = gradient
    }
}
