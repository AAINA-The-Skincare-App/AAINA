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
        dateLabel.backgroundColor = UIColor.systemGray5
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
        
        dateLabel.layer.borderWidth = 0
        dateLabel.layer.borderColor = nil

        if isToday && isSelected {
            dateLabel.backgroundColor = .systemRed
            dateLabel.textColor = .white
        } else if isToday {
            dateLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.40)
            dateLabel.textColor = .label
        } else if isSelected {
            dateLabel.backgroundColor = UIColor(white: 0.70, alpha: 1)
            dateLabel.textColor = .label
            dateLabel.layer.borderWidth = 0.5
            dateLabel.layer.borderColor = UIColor.systemGray5.cgColor
        } else {
            dateLabel.backgroundColor = UIColor(white: 0.90, alpha: 1)
            dateLabel.textColor = .label
        }
    }
}
