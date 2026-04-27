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
    
    weak var delegate: HomeSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
    }
    
    func configure(title: String, showSegment: Bool, selectedIndex: Int = 0) {
        titleLabel.text = title
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        delegate?.didChangeSegment(index: sender.selectedSegmentIndex)
    }
}
