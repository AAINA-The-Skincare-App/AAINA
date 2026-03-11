//
//  SkinMatrixCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 12/02/26.
//


import UIKit

class SkinMatrixCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainerView.layer.cornerRadius =
            iconContainerView.bounds.height / 2
    }
    
    private func setupUI() {

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.layer.cornerRadius = 22
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        
        
        
        iconContainerView.backgroundColor =
            UIColor.systemGreen.withAlphaComponent(0.15)
        
        iconImageView.tintColor = .systemGreen
        
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        
        percentLabel.textColor = .systemGreen
    }
    
    func configure(
        icon: String,
        title: String,
        subtitle: String,
        percent: Int
    ) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        percentLabel.text = "+\(percent)%"
        progressView.setProgress(Float(percent)/100, animated: false)
    }
}
