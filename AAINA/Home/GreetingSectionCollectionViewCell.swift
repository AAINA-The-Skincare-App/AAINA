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

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupUI() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor.ainaTextSecondary
    }

    func configure(name: String) {
        titleLabel.text = "Hello, \(name)"
        subtitleLabel.text = "Let’s start your Glow!"
    }
}
