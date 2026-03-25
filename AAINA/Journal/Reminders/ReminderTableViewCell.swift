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
        let f = DateFormatter(); f.dateFormat = "EEEE, dd/MM/yy"; return f
    }()

    func configure(with event: EKEvent) {
        titleLabel.text = event.title ?? "Untitled"
        timeLabel.text  = event.startDate.map { Self.timeFmt.string(from: $0) } ?? ""
        dateLabel.text  = event.startDate.map { Self.dateFmt.string(from: $0) } ?? ""
    }
}
