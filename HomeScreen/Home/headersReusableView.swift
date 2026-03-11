//
//  headersReusableView.swift
//  homeScreenApp
//
//  Created by GEU on 10/02/26.
//

import UIKit

class headersReusableView: UICollectionReusableView {
    
    static let identifier = "headersReusableView"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var delegate: HomeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(type(of: self))
        print("Loaded:", type(of: self))
        chevronButton.isHidden = true
        segmentedControl.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        chevronButton.isHidden = true
        segmentedControl.isHidden = true
        delegate = nil
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        delegate?.routineSegmentChanged(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func chevronTapped(_ sender: UIButton) {
        delegate?.chevronTapped()
    }
    
    func configure(
        title: String,
        showChevron: Bool = false,
        showSegment: Bool = false,
        selectedSegment: Int = 0
    ) {
        titleLabel.text = title
        chevronButton.isHidden = !showChevron
        segmentedControl.isHidden = !showSegment
        segmentedControl.selectedSegmentIndex = selectedSegment
    }
}
