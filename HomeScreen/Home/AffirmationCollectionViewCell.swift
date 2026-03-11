//
//  AffirmationCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 07/02/26.
//

import UIKit

class AffirmationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    var onShareTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }

    private func setupUI() {

        containerView.layer.cornerRadius = 22
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        containerView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.15)
        
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        shareButton.tintColor = .label
    }
    
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        onShareTapped?()
    }
}
