//
//  InsightSectionCollectionViewCell.swift
//  AAINA
//

import UIKit

final class InsightSectionCollectionViewCell: UICollectionViewCell {

    static let identifier = "InsightSectionCollectionViewCell"

    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    var onActionTapped: (() -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Rounded card
        containerView.layer.cornerRadius = 24

        // Pill button
        actionButton.layer.cornerRadius = actionButton.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.text = nil
        onActionTapped = nil
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card styling
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        containerView.layer.cornerRadius = 24
        containerView.layer.cornerCurve = .continuous
        containerView.layer.masksToBounds = false

        // Subtle shadow (matches your UI)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        containerView.layer.shadowRadius = 16

        // Description label
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.adjustsFontForContentSizeCategory = true

        // Button styling
        actionButton.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.25)
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        actionButton.clipsToBounds = true

    }

    // MARK: - Configure

    func configure(description: String) {
        descriptionLabel.text = description
        actionButton.setTitle("View Full Analysis", for: .normal)
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        onActionTapped?()
    }
}
