//
//  dateCollectionViewCell.swift
//  homeScreenApp
//
//  Created by GEU on 13/02/26.
//

import UIKit

class dateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    static let reuseIdentifier = "date_cell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make date label circular
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.layer.cornerRadius = dateLabel.bounds.height / 2
    }
    
    func configure(day: String,
                   date: String,
                   selected: Bool) {
        
        dayLabel.text = day
        dateLabel.text = date
        
        if selected {
            dateLabel.backgroundColor = .systemRed
            dateLabel.textColor = .white
        } else {
            dateLabel.backgroundColor = .clear
            dateLabel.textColor = .gray
        }
    }
}
