//
//  SkinMatrixSectionCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 28/03/26.
//

import UIKit

class SkinMatrixSectionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SkinMatrixSectionCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = 24
        
        // Make icon circular
        iconButton.layer.cornerRadius = iconButton.frame.height / 2
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
        
        iconButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .black
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.numberOfLines = 1
        progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        lowLabel.text = "Low"
        highLabel.text = "High"
        
        lowLabel.font = UIFont.systemFont(ofSize: 12)
        highLabel.font = UIFont.systemFont(ofSize: 12)
        
        lowLabel.textColor = UIColor.gray
        highLabel.textColor = UIColor.gray
    }
    
    
    func configure(
        title: String,
        subtitle: String,
        progress: Float,
        image: UIImage?,
        tintColor: UIColor = .systemGreen
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        progressView.progress = progress

        iconButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        iconButton.tintColor = tintColor
        iconButton.backgroundColor = tintColor.withAlphaComponent(0.15)

        progressView.progressTintColor = tintColor
    }
}
