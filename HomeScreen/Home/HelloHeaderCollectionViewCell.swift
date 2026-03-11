//
//  HelloHeaderCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 06/02/26.
//

import UIKit

class HelloHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(name: String) {
        helloLabel.text = "Hello, \(name)"
        secondLabel.text = "Let’s start your glow"
    }
}
