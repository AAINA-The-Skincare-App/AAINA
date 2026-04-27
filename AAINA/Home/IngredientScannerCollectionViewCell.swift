//
//  IngredientScannerCollectionViewCell.swift
//  AAINA
//

import UIKit

class IngredientScannerCollectionViewCell: UICollectionViewCell {

    static let identifier = "IngredientScannerCollectionViewCell"

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!

    var onInfoTapped: (() -> Void)?
    private var currentImageName = ""

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupImageArea()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bgImageView.image = nil
        onInfoTapped = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cardFrame = contentView.bounds.insetBy(dx: 16, dy: 16)
        containerView.frame = cardFrame

        let isFaceCard = currentImageName == "FemaleFace"
        let imageWidth = cardFrame.width * (isFaceCard ? 0.47 : 0.54)
        bgImageView.frame = isFaceCard
            ? CGRect(x: 0, y: -24, width: imageWidth, height: cardFrame.height + 24)
            : CGRect(x: -22, y: 22, width: imageWidth, height: cardFrame.height - 28)

        let textLeft = cardFrame.width * (isFaceCard ? 0.48 : 0.45)
        let buttonSize: CGFloat = 28
        infoButton.frame = CGRect(
            x: cardFrame.width - buttonSize - 24,
            y: cardFrame.height - buttonSize - 24,
            width: buttonSize,
            height: buttonSize
        )
        infoButton.layer.cornerRadius = buttonSize / 2

        let textRight = cardFrame.width - 22
        let textWidth = max(0, textRight - textLeft)
        titleLabel.frame = CGRect(x: textLeft, y: 42, width: textWidth, height: 24)
        descriptionLabel.frame = CGRect(x: textLeft, y: 78, width: textWidth - buttonSize - 14, height: 46)

        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }

    // MARK: - Configure

    func configure(title: String, description: String, imageName: String) {
        titleLabel.text          = title
        titleLabel.font          = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor     = UIColor.ainaTextPrimary
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85

        descriptionLabel.text      = description
        descriptionLabel.font      = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor.ainaTextSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.adjustsFontForContentSizeCategory = true
        bgImageView.image = UIImage(named: imageName)
        currentImageName = imageName
    }

    // MARK: - Card

    private func setupCard() {
        backgroundColor             = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor     = UIColor.ainaGlassElevated
        containerView.layer.cornerRadius  = 36
        containerView.layer.cornerCurve   = .continuous
        containerView.layer.masksToBounds = false
        containerView.layer.borderWidth   = 0
        containerView.layer.borderColor   = UIColor.clear.cgColor
        containerView.layer.shadowColor   = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.12
        containerView.layer.shadowRadius  = 14
        containerView.layer.shadowOffset  = CGSize(width: 0, height: 8)
    }

    private func setupImageArea() {
        bgImageView.contentMode   = .scaleAspectFit
        bgImageView.clipsToBounds = false

        infoButton.setTitle("i", for: .normal)
        infoButton.setTitleColor(.ainaCoralPink, for: .normal)
        infoButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        infoButton.backgroundColor = UIColor.ainaTintedGlassLight
        infoButton.layer.cornerRadius = 14
        infoButton.layer.cornerCurve = .continuous
        infoButton.layer.borderWidth = 1.5
        infoButton.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.9).cgColor
    }

    // MARK: - IBActions

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        onInfoTapped?()
    }
}
