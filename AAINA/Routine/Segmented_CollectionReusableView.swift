//
//  Segmented_CollectionReusableView.swift
//  ro
//
//  Created by GEU on 12/02/26.
//
import UIKit

class Segmented_CollectionReusableView: UICollectionReusableView {
    
    static let identifier = "Segmented_CollectionReusableView"
    @IBOutlet private var segmentedControl: UISegmentedControl!
      
    var segmentChanged: ((Int) -> Void)?
        override func awakeFromNib() {
            super.awakeFromNib()

            segmentedControl.removeAllSegments()
            segmentedControl.insertSegment(withTitle: "Morning", at: 0, animated: false)
            segmentedControl.insertSegment(withTitle: "Evening", at: 1, animated: false)
            segmentedControl.selectedSegmentIndex = 0
        }

       
        @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            segmentChanged?(sender.selectedSegmentIndex)
        }
    }
