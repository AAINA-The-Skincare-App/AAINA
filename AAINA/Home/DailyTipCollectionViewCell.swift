//
//  DailyTipCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class DailyTipCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "DailyTipCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 24
        
        // Shadow path updated after layout so it matches the rounded card
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Glass card — rgba(255,255,255,0.55) surface with coral tint
//        containerView.backgroundColor = UIColor.ainaTintedGlassMedium
//        containerView.layer.cornerRadius = 24
//        containerView.layer.cornerCurve = .continuous
//        containerView.clipsToBounds = false
//        
//        // Glass border
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
//        
//        // Shadow — --shadow-card token
//        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
//        containerView.layer.shadowOpacity = 0.10
//        containerView.layer.shadowRadius = 24
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        containerView.layer.masksToBounds = false
        
        
        containerView.backgroundColor = .clear

        containerView.applyGlass(cornerRadius: 24)

//        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
//        containerView.layer.shadowOpacity = 0.10
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
//        containerView.layer.shadowRadius = 20
        containerView.layer.masksToBounds = false

        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Icon
        tipImageView.contentMode = .scaleAspectFit
        tipImageView.tintColor = UIColor.ainaDustyRose
        
        // Title — "Daily Tip" label
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor.ainaDustyRose
        titleLabel.numberOfLines = 1
        
        // Tip body
        tipLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tipLabel.textColor = UIColor.ainaTextPrimary
        tipLabel.numberOfLines = 2
        tipLabel.lineBreakMode = .byWordWrapping
        tipLabel.adjustsFontSizeToFitWidth = false
        tipLabel.minimumScaleFactor = 1.0
        tipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        tipLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func configure(title: String, tip: String, image: UIImage?) {
        titleLabel.text = title
        tipLabel.text = tip
        tipImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
}
