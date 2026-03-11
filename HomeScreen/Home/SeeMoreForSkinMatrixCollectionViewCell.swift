//
//  SeeMoreForSkinMatrixCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 12/02/26.
//

import UIKit

protocol SkinMatrixToggleDelegate: AnyObject {
    func didTapSkinMatrixToggle()
}

class SeeMoreForSkinMatrixCollectionViewCell: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!

    weak var delegate: SkinMatrixToggleDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        delegate?.didTapSkinMatrixToggle()
    }

    func configure(isExpanded: Bool) {
        titleLabel.text = isExpanded ? "show less" : "show more"
        chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.right")
    }
}
