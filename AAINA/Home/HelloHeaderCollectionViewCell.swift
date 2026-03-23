//
//  HelloHeaderCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 06/02/26.
//

import UIKit

class HelloHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func configure(name: String) {
        firstLabel.text = "Hello, \(name)"
        secondLabel.text = "Let’s start your glow"
    }
}
