import UIKit

class EntryCollectionViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tagsStack: UIStackView!

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

    override func prepareForReuse() {
        super.prepareForReuse()
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter(); f.timeStyle = .short; return f
    }()

    func configure(entry: JournalEntry) {
        entryLabel.text = entry.note.isEmpty ? "No notes" : entry.note
        timeLabel.text  = Self.timeFmt.string(from: entry.date)

        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in entry.flareUps {
            tagsStack.addArrangedSubview(makeTagView(tag))
        }
        if !entry.photoFileNames.isEmpty {
            tagsStack.addArrangedSubview(makePhotoChip(count: entry.photoFileNames.count))
        }
    }

    private func makePhotoChip(count: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.12)
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon.tintColor    = .ainaDustyRose
        icon.contentMode  = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text      = "\(count)"
        label.font      = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .ainaDustyRose
        label.translatesAutoresizingMaskIntoConstraints = false

        [icon, label].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 24),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 12),
            icon.heightAnchor.constraint(equalToConstant: 12),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func makeTagView(_ text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .ainaTintedGlassLight
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .ainaDustyRose
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }
}
