//
//  ArticlesCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 13/04/26.
//

import UIKit

class ArticlesCollectionViewCell: UICollectionViewCell {

    static let identifier = "ArticlesCollectionViewCell"

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var metaContainerView: UIView!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 24
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        layer.masksToBounds = false
        layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 8)

        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.28
        titleLabel.layer.shadowRadius = 5
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)

        metaContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.74)
        metaContainerView.layer.cornerRadius = 14
        metaContainerView.layer.cornerCurve = .continuous
        metaContainerView.layer.borderWidth = 1
        metaContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        metaContainerView.clipsToBounds = true
        contentView.bringSubviewToFront(metaContainerView)
        contentView.bringSubviewToFront(titleLabel)

        metaLabel.font = .systemFont(ofSize: 14, weight: .medium)
        metaLabel.textColor = .ainaDustyRose
        metaLabel.textAlignment = .center
        metaLabel.numberOfLines = 1
        metaLabel.adjustsFontSizeToFitWidth = true
        metaLabel.minimumScaleFactor = 0.85
    }

    func configure(title: String, meta: String) {
        titleLabel.text = title
        metaLabel.attributedText = makeMetaText(meta)
        articleImageView.image = UIImage(named: title)
    }

    private func makeMetaText(_ meta: String) -> NSAttributedString {
        let textColor = UIColor.ainaDustyRose
        let result = NSMutableAttributedString()

        if let image = UIImage(systemName: "clock")?.withTintColor(textColor, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: "  "))
        }

        result.append(NSAttributedString(
            string: meta,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: textColor
            ]
        ))
        return result
    }

}
