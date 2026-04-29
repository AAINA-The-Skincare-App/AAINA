//
//  GreetingSectionCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class GreetingSectionCollectionViewCell: UICollectionViewCell {

    static let identifier = "GreetingSectionCollectionViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!

    var onProfileTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeProfileCircular()
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        titleLabel.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        titleLabel.textColor = UIColor.ainaCoralPink
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7

        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = UIColor.ainaTextPrimary
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.8

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        profileButton.configuration = nil
        profileButton.setImage(UIImage(systemName: "person", withConfiguration: symbolConfig), for: .normal)
        profileButton.tintColor = UIColor.ainaTextPrimary
        profileButton.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        profileButton.layer.cornerCurve = .circular
        profileButton.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        profileButton.layer.shadowOpacity = 0.08
        profileButton.layer.shadowRadius = 10
        profileButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        profileButton.imageView?.contentMode = .scaleAspectFit
    }

    private func makeProfileCircular() {
        profileButton.layoutIfNeeded()

        profileButton.layer.cornerRadius = min(profileButton.bounds.width, profileButton.bounds.height) / 2
        profileButton.clipsToBounds = false
        profileButton.layer.masksToBounds = false
    }

    @IBAction func handleProfileTapped(_ sender: UIButton) {
        onProfileTapped?()
    }

    func configure(name: String) {
        let title = NSMutableAttributedString(
            string: "Hello! ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.ainaCoralPink
            ]
        )
        title.append(NSAttributedString(
            string: "🌸",
            attributes: [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .baselineOffset: 4,
                .foregroundColor: UIColor.ainaCoralPink
            ]
        ))
        titleLabel.attributedText = title
        subtitleLabel.text = "Your glow, Thoughtfully crafted"
    }
}
