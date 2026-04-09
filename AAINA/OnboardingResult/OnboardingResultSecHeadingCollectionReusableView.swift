//
//  OnboardingResultSecHeadingCollectionReusableView.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class OnboardingResultSecHeadingCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = UIColor.ainaTextPrimary
        titleLabel.text = "Your Personalized Routine"
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
