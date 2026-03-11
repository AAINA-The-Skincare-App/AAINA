//
//  ProgressCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 13/02/26.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.layer.cornerRadius = 22
        containerView.backgroundColor = .secondarySystemBackground

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        containerView.layer.shadowRadius = 14

        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemBlue
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: 22
        ).cgPath
    }

    func configure(total: Int, completed: Int) {

        let progress = total == 0 ? 0 : Float(completed) / Float(total)

        stepsLabel.text = "\(completed)/\(total) Steps"
        subtitleLabel.text = "completed"

        progressView.setProgress(progress, animated: true)
    }
}
