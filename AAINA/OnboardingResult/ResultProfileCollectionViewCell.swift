//
//  ResultProfileCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 26/03/26.
//

import UIKit

final class ResultProfileCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ResultProfileCollectionViewCell"
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AgeLabel: UILabel!
    
    @IBOutlet weak var tZoneTitleLabel: UILabel!
    @IBOutlet weak var tZoneValueLabel: UILabel!
    
    @IBOutlet weak var uZoneTitleLabel: UILabel!
    @IBOutlet weak var uZoneValueLabel: UILabel!
    
    @IBOutlet weak var cZoneTitleLabel: UILabel!
    @IBOutlet weak var cZoneValueLabel: UILabel!
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardView.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // MARK: - Card Styling (AAINA Glass Style)
        
        cardView.backgroundColor = .ainaGlassElevated
        cardView.layer.cornerRadius = 20
        cardView.layer.cornerCurve = .continuous
        
        cardView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        cardView.layer.shadowOpacity = 0.10
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.masksToBounds = false
        
        // MARK: - Title
        
        profileTitleLabel.text = "Your Profile"
        profileTitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        profileTitleLabel.textColor = .ainaTextSecondary
        
        // MARK: - Name + Age
        
        nameLabel.font = .systemFont(ofSize: 30, weight: .medium)
        nameLabel.textColor = .ainaTextPrimary
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        
        AgeLabel.font = .systemFont(ofSize: 30, weight: .medium)
        AgeLabel.textColor = .ainaTextPrimary
        AgeLabel.numberOfLines = 1
        AgeLabel.adjustsFontSizeToFitWidth = true
        AgeLabel.minimumScaleFactor = 0.8
        
        // MARK: - Zone Titles
        
        tZoneTitleLabel.text = "T-zone:"
        uZoneTitleLabel.text = "U-zone:"
        cZoneTitleLabel.text = "C-zone:"
        
        [tZoneTitleLabel, uZoneTitleLabel, cZoneTitleLabel].forEach {
            $0?.font = .systemFont(ofSize: 16, weight: .regular)
            $0?.textColor = .ainaTextSecondary
        }
        
        // MARK: - Zone Values
        
        [tZoneValueLabel, uZoneValueLabel, cZoneValueLabel].forEach {
            $0?.font = .systemFont(ofSize: 18, weight: .regular)
            $0?.textColor = .ainaTextPrimary
        }
        
        // MARK: - Dividers
        
        [firstDividerView, secondDividerView].forEach {
            $0?.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.3)
        }
    }
    
    func configure(with onboardingData: OnboardingData, name: String = "Priya") {
        nameLabel.text = name
        
        if let age = calculateAge(from: onboardingData.birthYear) {
            AgeLabel.text = ", \(age)"
        } else {
            AgeLabel.text = ""
        }
        
        tZoneValueLabel.text = displayText(for: onboardingData.tZone)
        uZoneValueLabel.text = displayText(for: onboardingData.uZone)
        cZoneValueLabel.text = displayText(for: onboardingData.cZone)
    }
    
    private func calculateAge(from birthYear: Int?) -> Int? {
        guard let birthYear = birthYear else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - birthYear
    }
    
    private func displayText(for type: SkinType?) -> String {
        guard let type = type else { return "Normal" }
        
        let raw = type.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "Normal" }
        
        return raw.prefix(1).uppercased() + raw.dropFirst().lowercased()
    }
}
