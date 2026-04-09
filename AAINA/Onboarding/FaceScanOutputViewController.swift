//
//  FaceScanOutputViewController.swift
//  AAINA
//

import UIKit

final class FaceScanOutputViewController: UIViewController {

    // MARK: - Input
    var scanResult: FaceScanResult!
    var dataModel: AppDataModel!
    var onboardingData: OnboardingData!

    // MARK: - UI
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let continueBtn  = UIButton(type: .system)

    // Decorative blobs
    private let blob1 = UIView()
    private let blob2 = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.applyAINABackground()
        setupBlobs()
        setupScrollView()
        buildContent()
        setupContinueButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
    }

    // MARK: - Background blobs

    private func setupBlobs() {
        blob1.backgroundColor = UIColor.ainaCoralPink.withAlphaComponent(0.25)
        blob1.layer.cornerRadius = 160
        blob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob1)

        blob2.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.15)
        blob2.layer.cornerRadius = 130
        blob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blob2)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 320),
            blob1.heightAnchor.constraint(equalToConstant: 320),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            blob1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),

            blob2.widthAnchor.constraint(equalToConstant: 260),
            blob2.heightAnchor.constraint(equalToConstant: 260),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60),
            blob2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60)
        ])

        UIView.animate(
            withDuration: 8, delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) { self.blob1.transform = CGAffineTransform(translationX: -20, y: 20).scaledBy(x: 1.05, y: 1.05) }

        UIView.animate(
            withDuration: 10, delay: 1,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) { self.blob2.transform = CGAffineTransform(translationX: 15, y: -25).scaledBy(x: 1.08, y: 1.08) }
    }

    // MARK: - Scroll view

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -120),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    // MARK: - Content

    private func buildContent() {
        // Header
        let header = makeHeaderView()
        contentStack.addArrangedSubview(header)

        // Summary card
        if !scanResult.summary.isEmpty {
            contentStack.addArrangedSubview(makeSummaryCard())
        }

        // Skin type + skin tone row
        let typeRow = UIStackView(arrangedSubviews: [
            makePillCard(icon: "drop.fill",  label: "Skin Type", value: scanResult.skinType, color: .ainaDustyRose),
            makePillCard(icon: "sun.max.fill", label: "Skin Tone", value: scanResult.skinTone, color: .ainaCoralPink)
        ])
        typeRow.axis = .horizontal
        typeRow.spacing = 12
        typeRow.distribution = .fillEqually
        contentStack.addArrangedSubview(typeRow)

        // Concerns card
        if !scanResult.concerns.isEmpty {
            contentStack.addArrangedSubview(makeConcernsCard())
        }

        // Disclaimer
        contentStack.addArrangedSubview(makeDisclaimerCard())
    }

    // MARK: - Card builders

    private func makeHeaderView() -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = .clear

        let icon = UIImageView(image: UIImage(systemName: "sparkles"))
        icon.tintColor = .ainaDustyRose
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Your Skin Analysis"
        title.font = .systemFont(ofSize: 26, weight: .bold)
        title.textColor = .ainaTextPrimary
        title.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Here's what we found from your face scan"
        sub.font = .systemFont(ofSize: 14)
        sub.textColor = .ainaTextSecondary
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(icon)
        wrapper.addSubview(title)
        wrapper.addSubview(sub)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: wrapper.topAnchor),
            icon.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),

            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),

            sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            sub.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            sub.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            sub.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    private func makeSummaryCard() -> UIView {
        let card = makeCard()

        let sectionLabel = makeSectionLabel("Overview")
        let text = UILabel()
        text.text = scanResult.summary
        text.font = .systemFont(ofSize: 15)
        text.textColor = .ainaTextPrimary
        text.numberOfLines = 0
        text.lineBreakMode = .byWordWrapping

        let stack = UIStackView(arrangedSubviews: [sectionLabel, text])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makePillCard(icon iconName: String, label: String, value: String, color: UIColor) -> UIView {
        let card = makeCard()

        let iconView = UIImageView(image: UIImage(systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let labelLbl = UILabel()
        labelLbl.text = label
        labelLbl.font = .systemFont(ofSize: 11, weight: .semibold)
        labelLbl.textColor = .ainaTextTertiary
        labelLbl.translatesAutoresizingMaskIntoConstraints = false

        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = .systemFont(ofSize: 17, weight: .bold)
        valueLbl.textColor = .ainaTextPrimary
        valueLbl.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(labelLbl)
        card.addSubview(valueLbl)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            labelLbl.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            labelLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            labelLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),

            valueLbl.topAnchor.constraint(equalTo: labelLbl.bottomAnchor, constant: 4),
            valueLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            valueLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            valueLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makeConcernsCard() -> UIView {
        let card = makeCard()

        let sectionLabel = makeSectionLabel("Concerns Detected")
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 0
        rows.translatesAutoresizingMaskIntoConstraints = false

        for (idx, concern) in scanResult.concerns.enumerated() {
            if idx > 0 {
                let sep = UIView()
                sep.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.2)
                sep.translatesAutoresizingMaskIntoConstraints = false
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                rows.addArrangedSubview(sep)
            }
            rows.addArrangedSubview(makeConcernRow(concern))
        }

        let outer = UIStackView(arrangedSubviews: [sectionLabel, rows])
        outer.axis = .vertical
        outer.spacing = 12
        outer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(outer)

        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            outer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            outer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            outer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func makeConcernRow(_ concern: FaceScanConcern) -> UIView {
        let row = UIView()
        row.backgroundColor = .clear

        let dot = UIView()
        dot.backgroundColor = severityColor(concern.severity)
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false

        let nameLbl = UILabel()
        nameLbl.text = concern.name
        nameLbl.font = .systemFont(ofSize: 14, weight: .medium)
        nameLbl.textColor = .ainaTextPrimary

        let areaLbl = UILabel()
        areaLbl.text = concern.area
        areaLbl.font = .systemFont(ofSize: 12)
        areaLbl.textColor = .ainaTextSecondary

        let textStack = UIStackView(arrangedSubviews: [nameLbl, areaLbl])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let badge = makeSeverityBadge(concern.severity)

        row.addSubview(dot)
        row.addSubview(textStack)
        row.addSubview(badge)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -8),

            badge.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            badge.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeSeverityBadge(_ severity: String) -> UIView {
        let pill = UIView()
        pill.backgroundColor = severityColor(severity).withAlphaComponent(0.15)
        pill.layer.cornerRadius = 10

        let lbl = UILabel()
        lbl.text = severity.capitalized
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = severityColor(severity)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            lbl.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            lbl.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            lbl.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -10)
        ])
        pill.translatesAutoresizingMaskIntoConstraints = false
        return pill
    }

    private func makeDisclaimerCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.12)
        card.layer.cornerRadius = 14

        let icon = UIImageView(image: UIImage(systemName: "info.circle",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)))
        icon.tintColor = .ainaTextTertiary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let lbl = UILabel()
        lbl.text = "AI analysis is for guidance only and not a substitute for professional dermatology advice."
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .ainaTextSecondary
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(icon)
        card.addSubview(lbl)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),

            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            lbl.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: - Continue button

    private func setupContinueButton() {
        continueBtn.setTitle("Continue to My Routine", for: .normal)
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        continueBtn.backgroundColor = .ainaDustyRose
        continueBtn.layer.cornerRadius = 16
        continueBtn.layer.shadowColor = UIColor.ainaDustyRose.cgColor
        continueBtn.layer.shadowOpacity = 0.3
        continueBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        continueBtn.layer.shadowRadius = 10
        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueBtn)

        NSLayoutConstraint.activate([
            continueBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueBtn.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc private func continueTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let resultVC = storyboard.instantiateViewController(
            withIdentifier: "OnboardingResultViewController"
        ) as? OnboardingResultViewController else { return }
        resultVC.onboardingData = onboardingData
        resultVC.dataModel = dataModel
        navigationController?.pushViewController(resultVC, animated: true)
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .ainaGlassElevated
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        return card
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text.uppercased()
        lbl.font = .systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = .ainaDustyRose
        lbl.letterSpacing(0.8)
        return lbl
    }

    private func severityColor(_ severity: String) -> UIColor {
        switch severity.lowercased() {
        case "mild":     return .ainaSageGreen
        case "moderate": return .ainaCoralPink
        case "notable":  return .ainaSoftRed
        default:         return .ainaTextSecondary
        }
    }
}

// MARK: - UILabel letter spacing helper

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attrs = NSMutableAttributedString(string: text)
        attrs.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: attrs.length))
        attributedText = attrs
    }
}
