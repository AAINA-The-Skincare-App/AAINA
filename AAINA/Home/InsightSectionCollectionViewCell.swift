//
//  InsightSectionCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 28/03/26.
//

import UIKit

final class InsightSectionCollectionViewCell: UICollectionViewCell {

    static let identifier = "InsightSectionCollectionViewCell"

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!

    @IBOutlet weak var insightTitleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!

    @IBOutlet weak var footerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 24
        iconButton.layer.cornerRadius = iconButton.bounds.height / 2
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .clear

        containerView.applyGlass(cornerRadius: 24)

//        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
//        containerView.layer.shadowOpacity = 0.10
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
//        containerView.layer.shadowRadius = 20
        containerView.layer.masksToBounds = false

        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        iconButton.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        iconButton.tintColor = .black
        iconButton.isUserInteractionEnabled = false
        iconButton.imageView?.contentMode = .scaleAspectFit
        iconButton.setImage(UIImage(systemName: "chart.line.uptrend.xyaxis"), for: .normal)

        headerTitleLabel.textColor = .black
        headerTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        headerTitleLabel.numberOfLines = 1

        insightTitleLabel.textColor = .black
        insightTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        insightTitleLabel.numberOfLines = 1

        lowLabel.textColor = UIColor.systemGray2
        lowLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lowLabel.numberOfLines = 1

        highLabel.textColor = UIColor.systemGray2
        highLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        highLabel.numberOfLines = 1
        highLabel.textAlignment = .right

        footerLabel.textColor = UIColor.systemGray2
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.numberOfLines = 1

        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true

        if let sublayers = progressView.layer.sublayers, sublayers.count > 1 {
            sublayers[1].cornerRadius = 4
            sublayers[1].masksToBounds = true
        }
    }

    func configure(
        headerTitle: String,
        insightTitle: String,
        progress: Float,
        lowText: String,
        highText: String,
        footerText: String,
        icon: UIImage? = UIImage(systemName: "chart.line.uptrend.xyaxis")
    ) {
        headerTitleLabel.text = headerTitle
        insightTitleLabel.text = insightTitle
        lowLabel.text = lowText
        highLabel.text = highText
        footerLabel.text = footerText

        iconButton.setImage(icon, for: .normal)
        progressView.setProgress(max(0, min(progress, 1)), animated: false)
    }
}
