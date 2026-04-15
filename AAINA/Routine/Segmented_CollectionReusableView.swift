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
        
        // Remove default segments
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Morning", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Evening", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
 
        
        // Background (outer pill)
        segmentedControl.backgroundColor = UIColor(
            red: 235/255,
            green: 220/255,
            blue: 225/255,
            alpha: 1
        )
        
        // Selected segment (inner pill)
        segmentedControl.selectedSegmentTintColor = .white
        
        // Rounded pill shape
        segmentedControl.layer.cornerRadius = 22
        segmentedControl.layer.masksToBounds = true
        
        // Remove borders
        segmentedControl.layer.borderWidth = 0
        segmentedControl.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        segmentedControl.layer.shadowOpacity = 0.10
    
      
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }

       
        @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            segmentChanged?(sender.selectedSegmentIndex)
        }
    }
