//
//  HomeSectionHeader.swift
//  AAINA
//
//  Created by GEU on 30/03/26.
//

import UIKit

protocol HomeSectionHeaderDelegate: AnyObject {
    func didChangeSegment(index: Int)
}

class HomeSectionHeader: UICollectionReusableView {
    
    static let identifier = "HomeSectionHeader"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegate: HomeSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        segmentControl.removeAllSegments()
        segmentControl.insertSegment(withTitle: "Morning", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "Evening", at: 1, animated: false)
        segmentControl.selectedSegmentIndex = 0
        
        segmentControl.backgroundColor = UIColor.systemGray5
        segmentControl.selectedSegmentTintColor = .white
        
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.label],
            for: .normal
        )
        
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.label],
            for: .selected
        )
        
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func configure(title: String, showSegment: Bool, selectedIndex: Int = 0) {
        titleLabel.text = title
        
        segmentControl.isHidden = !showSegment
        segmentControl.isUserInteractionEnabled = showSegment
        
        if showSegment {
            segmentControl.selectedSegmentIndex = selectedIndex
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        delegate?.didChangeSegment(index: sender.selectedSegmentIndex)
    }
}
