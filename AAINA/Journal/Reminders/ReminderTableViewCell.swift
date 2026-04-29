import UIKit
import EventKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerView.backgroundColor = .ainaGlassSurface
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        containerView.layer.shadowOpacity = 0.10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = false
    }

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter(); f.timeStyle = .short; return f
    }()

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEE, d MMM"; return f
    }()

    func configure(with event: EKEvent) {
        titleLabel.text          = event.title ?? "Untitled"
        titleLabel.font          = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        guard let date = event.startDate else {
            timeLabel.text = ""; dateLabel.text = ""; return
        }

        timeLabel.text      = Self.timeFmt.string(from: date)
        timeLabel.isHidden  = false
        timeLabel.font      = .systemFont(ofSize: 13)
        timeLabel.textColor = .secondaryLabel

        let cal = Calendar.current
        if cal.isDateInToday(date) {
            dateLabel.text = "Today"
        } else if cal.isDateInTomorrow(date) {
            dateLabel.text = "Tomorrow"
        } else {
            dateLabel.text = Self.dateFmt.string(from: date)
        }
        dateLabel.font      = .systemFont(ofSize: 13)
        dateLabel.textColor = .tertiaryLabel
    }
}
