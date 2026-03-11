//
//  InsideRoutineCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 13/02/26.
//

import UIKit

class InsideRoutineCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    var toggleHandler: (() -> Void)?

    private var isDone = false

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .secondarySystemBackground

        separatorView.backgroundColor = .systemGray4

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        checkButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)
    }

    func configure(title: String, detail: String, done: Bool) {

        titleLabel.text = title
        detailLabel.text = detail

        isDone = done

        updateUI()
    }

    private func updateUI() {

        if isDone {

            checkButton.setImage(
                UIImage(systemName: "checkmark.circle.fill"),
                for: .normal
            )

            checkButton.tintColor = .systemGreen

        } else {

            checkButton.setImage(
                UIImage(systemName: "circle"),
                for: .normal
            )

            checkButton.tintColor = .systemGray3
        }
    }

    @IBAction func toggleTapped(_ sender: UIButton) {

        isDone.toggle()

        updateUI()

        toggleHandler?()
    }
}
