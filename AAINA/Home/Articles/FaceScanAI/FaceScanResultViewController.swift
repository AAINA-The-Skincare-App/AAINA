import UIKit

final class FaceScanResultViewController: UIViewController {

    var capturedImage: UIImage?
    var result: FaceScanResult!

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Skin Analysis"
        view.applyAINABackground()
        setupNavigation()
        setupScrollView()
        buildContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
    }

    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ainaTextPrimary
    }

    @objc private func closeTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -22),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -44)
        ])
    }

    private func buildContent() {
        stackView.addArrangedSubview(makeHeaderView())
        stackView.addArrangedSubview(makeImageCard())
        stackView.addArrangedSubview(makeSummaryCard())
        stackView.addArrangedSubview(makePillsRow())

        if result.concerns.isEmpty {
            stackView.addArrangedSubview(makeEmptyCard())
        } else {
            stackView.addArrangedSubview(makeDetectionsCard())
        }
    }

    private func makeHeaderView() -> UIView {
        let wrapper = UIView()

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .ainaTextPrimary
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        backButton.layer.cornerRadius = 19
        backButton.layer.cornerCurve = .continuous
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Your Skin Analysis"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .ainaTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(backButton)
        wrapper.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 38),
            backButton.heightAnchor.constraint(equalToConstant: 38),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -50),
            titleLabel.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor)
        ])

        return wrapper
    }

    private func makeImageCard() -> UIView {
        let imageView = UIImageView(image: capturedImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        imageView.layer.cornerCurve = .continuous
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        return imageView
    }

    private func makeSummaryCard() -> UIView {
        makeTextCard(title: "Summary", body: result.summary)
    }

    private func makePillsRow() -> UIView {
        let row = UIStackView(arrangedSubviews: [
            makePill(title: "Skin Type", value: result.skinType, icon: "drop.fill"),
            makePill(title: "Skin Tone", value: result.skinTone, icon: "sun.max.fill")
        ])
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }

    private func makePill(title: String, value: String, icon: String) -> UIView {
        let card = makeCard()
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .ainaDustyRose
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .ainaTextSecondary

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        valueLabel.textColor = .ainaTextPrimary
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(textStack)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makeDetectionsCard() -> UIView {
        let card = makeCard()
        let title = makeTitleLabel("Detected Concerns")
        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 12

        result.concerns.forEach { rows.addArrangedSubview(makeConcernRow($0)) }

        let outer = UIStackView(arrangedSubviews: [title, rows])
        outer.axis = .vertical
        outer.spacing = 14
        outer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            outer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            outer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            outer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func makeConcernRow(_ concern: FaceScanConcern) -> UIView {
        let row = UIView()
        let icon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        icon.tintColor = severityColor(concern.severity)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = concern.name
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.textColor = .ainaTextPrimary

        let area = UILabel()
        area.text = concern.area
        area.font = .systemFont(ofSize: 14, weight: .regular)
        area.textColor = .ainaTextSecondary
        area.numberOfLines = 0

        let badge = PaddingLabel()
        badge.text = concern.severity.capitalized
        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = severityColor(concern.severity)
        badge.backgroundColor = severityColor(concern.severity).withAlphaComponent(0.14)
        badge.layer.cornerRadius = 11
        badge.clipsToBounds = true
        badge.padding = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

        let textStack = UIStackView(arrangedSubviews: [title, area])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        badge.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(icon)
        row.addSubview(textStack)
        row.addSubview(badge)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            icon.topAnchor.constraint(equalTo: row.topAnchor, constant: 4),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            textStack.topAnchor.constraint(equalTo: row.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            badge.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            badge.centerYAnchor.constraint(equalTo: title.centerYAnchor)
        ])

        return row
    }

    private func makeEmptyCard() -> UIView {
        makeTextCard(title: "Detected Concerns", body: "No clear visible concerns were detected in this scan.")
    }

    private func makeTextCard(title: String, body: String) -> UIView {
        let card = makeCard()
        let titleLabel = makeTitleLabel(title)
        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = .ainaTextSecondary
        bodyLabel.numberOfLines = 0

        let outer = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        outer.axis = .vertical
        outer.spacing = 10
        outer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            outer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            outer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            outer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .ainaTextPrimary
        return label
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .ainaGlassElevated
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 16
        return card
    }

    private func severityColor(_ severity: String) -> UIColor {
        switch severity.lowercased() {
        case "mild": return .ainaSageGreen
        case "moderate": return .ainaCoralPink
        case "notable": return .ainaSoftRed
        default: return .ainaDustyRose
        }
    }
}
