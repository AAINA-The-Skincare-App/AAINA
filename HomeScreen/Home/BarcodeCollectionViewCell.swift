//
//  BarcodeCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 06/02/26.
//

import UIKit

class BarcodeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var barcodeImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }
    private func setupUI() {
        
        containerView.layer.cornerRadius = 22
        containerView.backgroundColor = .white
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .tertiaryLabel

        barcodeImageView.image = UIImage(systemName: "barcode.viewfinder")
        barcodeImageView.tintColor = .systemBlue
    }
    func configure(title: String, description: String, iconSystemName: String, showChevron: Bool) {
        titleLabel.text = title
        descriptionLabel.text = description
        barcodeImageView.image = UIImage(systemName: iconSystemName)
        barcodeImageView.tintColor = .systemBlue
        arrowImageView.isHidden = !showChevron
    }
}
