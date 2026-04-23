//
//  AAINAColors.swift
//  AAINA
//
//  AAINA complete color & gradient system — single source of truth.
//

import UIKit

// MARK: - AINA Color Palette

extension UIColor {

    // Primary palette
    static let ainaCoralPink  = UIColor(red: 232/255, green: 154/255, blue: 160/255, alpha: 1) // #E89AA0
    static let ainaLightBlush = UIColor(red: 244/255, green: 214/255, blue: 216/255, alpha: 1) // #F4D6D8
    static let ainaDustyRose  = UIColor(red: 199/255, green: 122/255, blue: 156/255, alpha: 1) // #C77A9C
    static let ainaRoseLight  = UIColor(red: 217/255, green: 148/255, blue: 180/255, alpha: 1) // #D994B4

    // Text
    static let ainaTextPrimary   = UIColor(red:  42/255, green:  42/255, blue:  42/255, alpha: 1) // #2A2A2A
    static let ainaTextSecondary = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1) // #8A8A8A
    static let ainaTextTertiary  = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1) // #BABABA

    // Semantic / status
    static let ainaSageGreen = UIColor(red:  91/255, green: 173/255, blue: 132/255, alpha: 1) // #5BAD84
    static let ainaSoftRed   = UIColor(red: 232/255, green: 112/255, blue: 112/255, alpha: 1) // #E87070

    // Glass surfaces
    static let ainaGlassSurface  = UIColor.white.withAlphaComponent(0.55)
    static let ainaGlassElevated = UIColor.white.withAlphaComponent(0.72)

    // Tinted glass fills — coral tint at varying opacities
    static let ainaTintedGlassLight  = UIColor(red: 232/255, green: 154/255, blue: 160/255, alpha: 0.20)
    static let ainaTintedGlassMedium = UIColor(red: 232/255, green: 154/255, blue: 160/255, alpha: 0.35)

    // Card shadow base (use with shadowOpacity 0.10 for --shadow-card)
    static let ainaCardShadowColor = UIColor(red: 180/255, green: 100/255, blue: 140/255, alpha: 1)
}

// MARK: - Page Background Gradient

extension UIView {
    // Call from both `viewDidLoad` and `viewDidLayoutSubviews`.
    func applyAINABackground() {
        let name = "ainaBackground"
        if let existing = layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer {
            existing.frame = bounds
            return
        }
        let gradient = CAGradientLayer()
        gradient.name = name
        // linear-gradient(145deg, #FDF0F2 0%, #F9E5E8 35%, #F0D8EC 70%, #EDD8F0 100%)
        gradient.colors = [
            UIColor(red: 253/255, green: 240/255, blue: 242/255, alpha: 1).cgColor,
            UIColor(red: 249/255, green: 229/255, blue: 232/255, alpha: 1).cgColor,
            UIColor(red: 240/255, green: 216/255, blue: 236/255, alpha: 1).cgColor,
            UIColor(red: 237/255, green: 216/255, blue: 240/255, alpha: 1).cgColor
        ]
        gradient.locations = [0, 0.35, 0.70, 1.0]
        // 145deg ≈ startPoint top-left, endPoint bottom-right with slight tilt
        gradient.startPoint = CGPoint(x: 0.1, y: 0)
        gradient.endPoint   = CGPoint(x: 0.9, y: 1)
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }

    func applyAINABlobBackground() {
        applyAINABackground()

        let topTag = 84001
        let bottomTag = 84002

        if viewWithTag(topTag) == nil {
            let topBlob = makeAINABlob(size: 180, color: .ainaCoralPink, alpha: 0.28)
            topBlob.tag = topTag
            insertSubview(topBlob, at: 0)

            NSLayoutConstraint.activate([
                topBlob.topAnchor.constraint(equalTo: topAnchor, constant: 40),
                topBlob.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 80),
                topBlob.widthAnchor.constraint(equalToConstant: 180),
                topBlob.heightAnchor.constraint(equalToConstant: 180)
            ])
        }

        if viewWithTag(bottomTag) == nil {
            let bottomBlob = makeAINABlob(size: 260, color: .ainaRoseLight, alpha: 0.22)
            bottomBlob.tag = bottomTag
            insertSubview(bottomBlob, at: 0)

            NSLayoutConstraint.activate([
                bottomBlob.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 120),
                bottomBlob.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -100),
                bottomBlob.widthAnchor.constraint(equalToConstant: 260),
                bottomBlob.heightAnchor.constraint(equalToConstant: 260)
            ])
        }
    }

    private func makeAINABlob(size: CGFloat, color: UIColor, alpha: CGFloat) -> UIView {
        let blob = UIView()
        blob.backgroundColor = color.withAlphaComponent(alpha)
        blob.layer.cornerRadius = size / 2
        blob.translatesAutoresizingMaskIntoConstraints = false

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = size / 2
        blur.clipsToBounds = true
        blob.addSubview(blur)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: blob.topAnchor),
            blur.bottomAnchor.constraint(equalTo: blob.bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: blob.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: blob.trailingAnchor)
        ])

        return blob
    }
}
