//
//  TimelineCollectionViewCell.swift
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    static let reuseIdentifier = "time_cell"
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // circle style
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutIfNeeded()

        let side = min(dateLabel.bounds.width,
                       dateLabel.bounds.height)

        dateLabel.layer.cornerRadius = side / 2
        dateLabel.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        dateLabel.layer.cornerRadius = 0
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = nil
    }


    func configure(day: String,
                   date: String,
                   isToday: Bool,
                   isSelected: Bool) {

        dayLabel.text = day
        dateLabel.text = date

        // Reset border by default
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = nil

        // Priority: selected state on today stays bold; otherwise today is light
        if isToday && isSelected {
            // Actively selected today: bold red
            dateLabel.backgroundColor = .systemRed
            dateLabel.textColor = .white
        } else if isToday {
            // Today but not selected: lighter/red-tinted appearance
            dateLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.40)
            dateLabel.textColor = .label
        } else if isSelected {
            // Selected non-today
            dateLabel.backgroundColor = UIColor(white: 0.70, alpha: 1)
            dateLabel.textColor = .label
            dateLabel.layer.borderWidth = 0.5
            dateLabel.layer.borderColor = UIColor.systemGray5.cgColor
        } else {
            // Default non-today
            dateLabel.backgroundColor = UIColor(white: 0.90, alpha: 1)
            dateLabel.textColor = .label
        }
    }


}
