//
//  SkinMatrixCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 12/02/26.
//


import UIKit

class SkinMatrixCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var icon: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLbel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        
        icon.layer.shadowColor = UIColor.black.cgColor
        icon.layer.shadowOpacity = 0.15
        icon.layer.shadowOffset = CGSize(width: 0, height: 4)
        icon.layer.shadowRadius = 8
        icon.layer.masksToBounds = false

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24
        containerView.layer.cornerCurve = .continuous
        

        
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
    }
    
    func configure(
        icon: String,
        title: String,
        subtitle: String,
        percent: Int
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        progressView.setProgress(Float(percent)/100, animated: false)
    }
}
