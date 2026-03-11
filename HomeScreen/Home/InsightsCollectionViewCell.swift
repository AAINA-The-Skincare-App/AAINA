//
//  InsightsCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 10/02/26.
//

import UIKit

class InsightsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsTextLabel: UILabel!
    @IBOutlet weak var weeklyContainerView: UIView!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var verticalSeparatorView: UIView!
    
    @IBOutlet weak var routineTitleLabel: UILabel!
    @IBOutlet weak var routineValueLabel: UILabel!
    
    @IBOutlet weak var scansTitleLabel: UILabel!
    @IBOutlet weak var scansValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconContainerView.layer.cornerRadius = iconContainerView.bounds.height / 2
        weeklyContainerView.layer.cornerRadius = weeklyContainerView.bounds.height / 2
        
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: 22
        ).cgPath
    }
    
    private func setupUI() {
        
        contentView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 22
        containerView.backgroundColor = .white
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        
        
        
        iconImageView.tintColor = .label
        
        pointsLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        pointsTextLabel.textColor = .secondaryLabel
        
        weeklyContainerView.backgroundColor =
        UIColor.systemBlue.withAlphaComponent(0.15)
        weeklyLabel.textColor = .systemBlue
        
        descriptionLabel.textColor = .secondaryLabel
        
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemBlue
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        
        topSeparatorView.backgroundColor = .separator
        verticalSeparatorView.backgroundColor = .separator
        
        routineTitleLabel.text = "Routine Consistency"
        scansTitleLabel.text = "Total Face Scans"
    }
    
    func configure(title: String,
                   points: Int,
                   weeklyPoints: Int,
                   description: String,
                   progress: Float,
                   routinePercent: Int,
                   scans: Int) {
        
        titleLabel.text = title
        pointsLabel.text = "\(points)"
        pointsTextLabel.text = "points"
        weeklyLabel.text = "+\(weeklyPoints) points this week"
        descriptionLabel.text = description
        
        progressView.setProgress(progress, animated: true)
        
        routineValueLabel.text = "\(routinePercent)%"
        scansValueLabel.text = "\(scans)"
    }
    
}
