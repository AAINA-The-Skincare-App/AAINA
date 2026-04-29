import UIKit

final class ArticleSourcesCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArticleSourcesCollectionViewCell"

    @IBOutlet weak var stackView: UIStackView!
    private let scrollView = UIScrollView()

    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let stackConstraints = contentView.constraints.filter {
            ($0.firstItem as AnyObject?) === stackView || ($0.secondItem as AnyObject?) === stackView
        } + constraints.filter {
            ($0.firstItem as AnyObject?) === stackView || ($0.secondItem as AnyObject?) === stackView
        }
        NSLayoutConstraint.deactivate(stackConstraints)
        stackView.removeFromSuperview()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        contentView.addSubview(scrollView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    func configure(sources: [ArticleSource]) {
        sources.forEach { source in
            let label = PaddingLabel()
            label.text = source.sourceTag
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = UIColor.ainaTextPrimary.withAlphaComponent(0.65)
            label.backgroundColor = UIColor.ainaGlassElevated
            label.layer.cornerRadius = 14
            label.clipsToBounds = true
            label.padding = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            stackView.addArrangedSubview(label)
        }
    }
}
