import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "TimelineCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("dayLabel:", dayLabel as Any)
        print("dateLabel:", dateLabel as Any)
        
        dayLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dayLabel.textColor = .secondaryLabel
        dayLabel.textAlignment = .center
        
        dateLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        dateLabel.backgroundColor = UIColor.ainaLightBlush.withAlphaComponent(0.4)
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = contentView.bounds.width
        dayLabel.frame = CGRect(x: 0, y: 8, width: w, height: 16)
        dateLabel.frame = CGRect(x: (w - 44) / 2, y: 28, width: 44, height: 44)
        dateLabel.layer.cornerRadius = 22
        dateLabel.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = nil
    }
    
    func configure(day: String, date: String, isToday: Bool, isSelected: Bool) {
        
        dayLabel.text = day
        dateLabel.text = date
        
        // RESET
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = nil
        dateLabel.layer.shadowOpacity = 0
        
        // 🎯 SELECTED (like 30)
        if isSelected {
            
            dateLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(0.3)
            dateLabel.textColor = .white
            
            // ✨ SOFT GLOW (inspo effect)
            dateLabel.layer.shadowColor = UIColor.ainaCoralPink.cgColor
            dateLabel.layer.shadowOpacity = 0.4
            dateLabel.layer.shadowRadius = 8
            dateLabel.layer.shadowOffset = .zero
            
        }
        
        // 🌸 TODAY (but not selected)
        else if isToday {
            
            dateLabel.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.18)
            dateLabel.textColor = UIColor.ainaTextPrimary
            
            dateLabel.layer.borderWidth = 1
            dateLabel.layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.25).cgColor
        }
        
        // ⚪ NORMAL (28, 29 — YOUR MAIN FIX)
        else {
            
            // ✨ SOFT WHITE (NOT PINK)
            dateLabel.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            
            // ✨ SUBTLE BORDER (important)
            dateLabel.layer.borderWidth = 1
            dateLabel.layer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
            
            dateLabel.textColor = UIColor.ainaTextPrimary
        }
    }
}
