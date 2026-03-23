//
//  DailyTipCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 06/02/26.
//

import UIKit

class DailyTipCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tipIconImageView: UIImageView!
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    private func setupUI() {
        setupCardView()
        setupIcons()
        setupLabels()
    }
    
    private func setupCardView() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = false
        
        // Soft shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
    }
    
    private func setupIcons() {
        tipIconImageView.contentMode = .scaleAspectFit
    }
    
    private func setupLabels() {
        
        let sectionTitleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let sectionTitleColor = UIColor.systemGray
        
        tipTitleLabel.font = sectionTitleFont
        tipTitleLabel.textColor = sectionTitleColor
        tipTitleLabel.numberOfLines = 1
        
        let descriptionFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let descriptionColor = UIColor.label
        
        tipDescriptionLabel.font = descriptionFont
        tipDescriptionLabel.textColor = descriptionColor
        tipDescriptionLabel.numberOfLines = 0
        
        tipDescriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func configure(with dailyTip: DailyTip) {
        tipTitleLabel.text = dailyTip.tipTitle
        tipDescriptionLabel.text = dailyTip.tipDesc

        tipIconImageView.image = UIImage(systemName: "sparkles")
    }
    
}
