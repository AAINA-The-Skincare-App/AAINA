//
//  ProfileCollectionViewCell.swift
//  Profile_Screen
//
//  Created by GEU on 11/02/26.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray5.cgColor

        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 10
        containerView.layer.masksToBounds = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        profileImageView.tintColor = .systemGray

    }

}

