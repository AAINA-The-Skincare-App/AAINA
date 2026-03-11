//
//  ReminderCollectionViewCell.swift
//  JournalUI
//
//  Created by GEU on 11/02/26.
//

import UIKit
import EventKit

class ReminderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    func configure(with event: EKEvent) {

            titleLabel.text = event.title ?? "Untitled"

            let formatter = DateFormatter()
            formatter.timeStyle = .short

            if let start = event.startDate {
                timeLabel.text = formatter.string(from: start)
            } else {
                timeLabel.text = ""
            }
        }
    }
