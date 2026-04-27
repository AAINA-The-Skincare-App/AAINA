//
//  SettingsCollectionViewCell.swift
//  Profile_Screen
//
//  Created by GEU on 11/02/26.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    
  
    @IBOutlet weak var row2Stack: UIStackView!
    
  
    @IBOutlet weak var icon2: UIImageView!
    

    @IBOutlet weak var title2Label: UILabel!
    
    // MARK: - Callback
    
    var onItemSelected: ((Int) -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        configureContent()
        setupTapGestures()
    }
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        containerView.backgroundColor = .ainaGlassSurface

        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
    }
    
    
    // MARK: - Configure Content
    
    private func configureContent() {
        
        // Row 1 - Language
//        icon1.image = UIImage(systemName: "globe")
//     
//        
//        title1Label.text = "Language"
//        title1Label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        
//        subtitle1Label.text = "English"
//        subtitle1Label.font = UIFont.systemFont(ofSize: 14)
//        subtitle1Label.textColor = .secondaryLabel
//        
        // Row 2 - Logout
        icon2.image = UIImage(systemName: "arrow.backward.square")
   
        
        title2Label.text = "Log out"
        title2Label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title2Label.textColor = .systemRed
    }
    
    
    // MARK: - Tap Gestures
    
    private func setupTapGestures() {
        
//        row1Stack.isUserInteractionEnabled = true
//        row2Stack.isUserInteractionEnabled = true
//        
//        let tap1 = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
//        row1Stack.addGestureRecognizer(tap1)
//        row1Stack.tag = 0
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        row2Stack.addGestureRecognizer(tap2)
        row2Stack.tag = 1
    }
    
    
    @objc private func rowTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            onItemSelected?(index)
        }
    }
}
