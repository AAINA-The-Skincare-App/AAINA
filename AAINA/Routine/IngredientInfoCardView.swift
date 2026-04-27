//
//  IngredientInfoCardView.swift
//  AAINA
//

import UIKit

final class IngredientInfoCardView: UIView {

    private let label = UILabel()
    private let icon = UIImageView()
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    private func setupUI() {

        
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.ainaCoralPink.withAlphaComponent(0.75).cgColor
        backgroundColor = .clear
        layer.shadowColor = UIColor.systemPink.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)

       
        gradient.colors = [
            UIColor.systemPink.withAlphaComponent(0.08).cgColor,
            UIColor.systemPink.withAlphaComponent(0.02).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 24
        layer.insertSublayer(gradient, at: 0)

   
        icon.image = UIImage(systemName: "sparkle")
        icon.tintColor = UIColor.ainaCoralPink
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])

      
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false

    
        let text = NSMutableAttributedString(
            string: "Curious about an ingredient? ",
            attributes: [.foregroundColor: UIColor.ainaTextSecondary]
        )

        let highlight = NSAttributedString(
            string: "Tap any ingredient pill ",
            attributes: [
                .foregroundColor: UIColor.ainaDustyRose,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        )

        let end = NSAttributedString(
            string: "to learn what it does for your skin.",
            attributes: [.foregroundColor: UIColor.ainaTextSecondary]
        )

        text.append(highlight)
        text.append(end)

        label.attributedText = text

    
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
