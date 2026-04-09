//
//  StartJourneyButtonCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class StartJourneyButtonCollectionViewCell: UICollectionViewCell {

    var onTap: (() -> Void)?
    
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        button.layer.cornerRadius = button.frame.height / 2
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        button.setTitle("Begin your AAINA Journey", for: .normal)
        button.backgroundColor = UIColor.ainaCoralPink
        button.setTitleColor(UIColor.ainaTextPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        button.layer.shadowOpacity = 0.10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 10
        button.layer.masksToBounds = false
    }

    // MARK: - Action
    @IBAction func didTapButton(_ sender: UIButton) {
        onTap?()
    }
}
