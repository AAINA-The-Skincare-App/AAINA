//
//  IngredientInfoCardView.swift
//  AAINA
//

import UIKit

final class IngredientInfoCardView: UIView {

    private let label = UILabel()
    private let icon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        // MARK: - Card Style
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor
        backgroundColor = UIColor.systemPink.withAlphaComponent(0.08)

        // MARK: - Icon
        icon.image = UIImage(systemName: "lightbulb.fill")
        icon.tintColor = .systemYellow
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18)
        ])

        // MARK: - Label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13) // 🔥 smaller clean text
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Attributed Text
        let text = NSMutableAttributedString(
            string: "Curious about an ingredient? ",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )

        let highlight = NSAttributedString(
            string: "Tap any ingredient pill ",
            attributes: [
                .foregroundColor: UIColor.systemPink,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        )

        let end = NSAttributedString(
            string: "to learn what it does for your skin.",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )

        text.append(highlight)
        text.append(end)

        label.attributedText = text

        // MARK: - Layout (HStack)
        let hStack = UIStackView(arrangedSubviews: [icon, label])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .top
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
