//
//  ScanCardCollectionViewCell.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//

import UIKit

class ScanCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        iconImageView.image = nil
    }
    
    private func setupUI() {
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        iconImageView.clipsToBounds = true
        subtitleLabel.numberOfLines = 2
    }
    
    func configure(title: String, subtitle: String, image: UIImage?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = image
    }
    
}
