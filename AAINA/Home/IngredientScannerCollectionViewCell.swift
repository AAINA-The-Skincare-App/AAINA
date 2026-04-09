//
//  IngredientScannerCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 30/03/26.
//

import UIKit

class IngredientScannerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "IngredientScannerCollectionViewCell"
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var scannerImageView: UIImageView!
    
    
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
        
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 3
        
        scannerImageView.contentMode = .scaleAspectFit
        scannerImageView.tintColor = .systemBlue
    }
    
    
    private func setupPillButton(_ button: UIButton, title: String) {
        
        button.backgroundColor = UIColor.systemGray5
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    
    func configure(
        description: String = "Scan labels for instant ingredient analysis for routine match and conflict check",
        image: UIImage? = UIImage(systemName: "barcode.viewfinder")
    ) {
        descriptionLabel.text = description
        scannerImageView.image = image
    }
}
