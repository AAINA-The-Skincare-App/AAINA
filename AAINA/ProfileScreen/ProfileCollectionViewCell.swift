//
//  ProfileCollectionViewCell.swift
//  Profile_Screen
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Main UI
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    
    // MARK: - Stats UI
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var daysTitleLabel: UILabel!
    
    @IBOutlet weak var JournalLabel: UILabel!
    @IBOutlet weak var JournalTitleLabel: UILabel!

    
    // MARK: - Divider
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var editButton: UIButton!


    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var memberLabel: UILabel!
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ageLabel.layer.cornerRadius = ageLabel.frame.height / 2
        ageLabel.clipsToBounds = true
        // Make profile image circular
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
       
        
        // Better shadow performance
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        // Container styling
        containerView.backgroundColor = .ainaGlassElevated
        containerView.layer.cornerRadius = 20

        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 20
        
        
        // Profile image styling
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2

        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.ainaLightBlush.cgColor
        profileImageView.layer.shadowColor = UIColor.ainaCoralPink.cgColor
        profileImageView.layer.shadowOpacity = 0.3
        profileImageView.layer.shadowRadius = 10
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileImageView.layer.masksToBounds = false

        profileImageView.contentMode = .scaleAspectFill
        
        // Name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        nameLabel.text = "Diya "
       
        memberLabel.text = "Member since 2025"
        ageLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(0.15)

        ageLabel.textAlignment = .center
        ageLabel.clipsToBounds = true

        // Stats Numbers
        //daysLabel.font = UIFont.boldSystemFont(ofSize: 18)
        //JournalLabel.font = UIFont.boldSystemFont(ofSize: 18)
    
        
        //daysLabel.textAlignment = .center
       // JournalLabel.textAlignment = .center
   
        
        // Stats Titles
        //daysTitleLabel.font = UIFont.systemFont(ofSize: 12)
       // JournalTitleLabel.font = UIFont.systemFont(ofSize: 12)
 
        //daysTitleLabel.textColor = .gray
        //JournalTitleLabel.textColor = .gray
        
        //daysTitleLabel.textAlignment = .center
       // JournalTitleLabel.textAlignment = .center
        
        // Default titles
        //daysTitleLabel.text = "Days active"
       // JournalTitleLabel.text = "Journals"
        editButton.layer.cornerRadius = 16
        editButton.clipsToBounds = true

        // Optional shadow (makes it premium)
        editButton.layer.shadowColor = UIColor.black.cgColor
        editButton.layer.shadowOpacity = 0.2
        editButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        editButton.layer.shadowRadius = 4
        editButton.layer.masksToBounds = false
//
//        // Divider styling
//        divider1?.backgroundColor = UIColor.systemGray5
       
    
        
    }
    
    
    // MARK: - Configure (Dynamic Data)
    func configure(name: String,
                   age: String,
                   days: String,
                   score: String,
                   journals: String,
                   image: UIImage?) {
        
        nameLabel.text = name
        ageLabel.text = age
        
        daysLabel.text = days
        JournalLabel.text = score
       
        profileImageView.image = image
    }
}
