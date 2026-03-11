//
//  EntryCollectionViewCell.swift
//  JournalUI
//
//  Created by GEU on 11/02/26.
//

import UIKit

class EntryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var entryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(text: String) {
        entryLabel.text = text
    }
}
