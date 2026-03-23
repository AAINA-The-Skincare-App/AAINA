//
//  GlassHelper.swift
//  JournalUI
//

import UIKit

extension UIView {
    /// Replaces the view's background with a UIGlassEffect visual effect view.
    /// Use this on plain UIViews (cards, containers) — NOT on UIButtons.
    @discardableResult
    func applyGlass(cornerRadius: CGFloat = 0) -> UIVisualEffectView {
        backgroundColor = .clear

        let glass = UIVisualEffectView(effect: UIGlassEffect())
        glass.layer.cornerRadius = cornerRadius
        glass.clipsToBounds = true
        glass.isUserInteractionEnabled = false
        glass.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(glass, at: 0)

        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        return glass
    }
}

/// Creates a pill-shaped glass button. The UIButton lives inside the
/// UIVisualEffectView's contentView so content is always above the glass layer.
/// - Returns: The outer UIVisualEffectView (add this to your hierarchy) and the inner UIButton.
func makeGlassButton(
    icon: String? = nil,
    title: String,
    height: CGFloat = 50,
    cornerRadius: CGFloat = 25
) -> (container: UIVisualEffectView, button: UIButton) {
    let glass = UIVisualEffectView(effect: UIGlassEffect())
    glass.layer.cornerRadius = cornerRadius
    glass.clipsToBounds = true
    glass.translatesAutoresizingMaskIntoConstraints = false
    glass.heightAnchor.constraint(equalToConstant: height).isActive = true

    let btn = UIButton(type: .system)
    if let icon {
        btn.setImage(UIImage(systemName: icon), for: .normal)
    }
    btn.setTitle("  \(title)", for: .normal)
    btn.tintColor = .label
    btn.setTitleColor(.label, for: .normal)
    btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    btn.translatesAutoresizingMaskIntoConstraints = false
    glass.contentView.addSubview(btn)

    NSLayoutConstraint.activate([
        btn.topAnchor.constraint(equalTo: glass.contentView.topAnchor),
        btn.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor),
        btn.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor),
        btn.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor)
    ])
    return (glass, btn)
}
