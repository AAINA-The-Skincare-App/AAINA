//
//  ProductChangesSectionView.swift
//  AAINA
//

import UIKit

final class ProductChangesSectionView: UIView {

    // MARK: - Outlets
    @IBOutlet private weak var productCard: UIView!
    @IBOutlet private weak var productRowsStack: UIStackView!
    @IBOutlet private weak var addProductButton: UIButton!

    // MARK: - Callbacks
    var onProductChangesUpdated: (([(name: String, isAdded: Bool)]) -> Void)?

    // MARK: - State
    private(set) var productChanges: [(name: String, isAdded: Bool)] = []

    // Reference to VC for presenting alert
    weak var presentingViewController: UIViewController?

    // MARK: - Factory
    static func create() -> ProductChangesSectionView {
        let views = Bundle.main.loadNibNamed("ProductChangesSectionView", owner: nil, options: nil)!
        return views.first as! ProductChangesSectionView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        productCard.backgroundColor = .ainaGlassElevated
        productCard.layer.cornerRadius = 16
        productCard.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        productCard.layer.shadowOpacity = 0.08
        productCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        productCard.layer.shadowRadius = 8
        productRowsStack.axis = .vertical
        productRowsStack.spacing = 8
        addProductButton.addTarget(self, action: #selector(addProductTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @IBAction private func addProductTapped() {
        guard let vc = presentingViewController else { return }
        let alert = UIAlertController(title: "Add Product Change",
                                      message: "Enter the product name",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Product name" }

        alert.addAction(UIAlertAction(title: "Added", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self?.addProductRow(name: name, isAdded: true)
        })
        alert.addAction(UIAlertAction(title: "Removed", style: .destructive) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self?.addProductRow(name: name, isAdded: false)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }

    // MARK: - Helpers
    func addProductRow(name: String, isAdded: Bool) {
        productChanges.append((name: name, isAdded: isAdded))

        // Separator above (skip for first row)
        if productRowsStack.arrangedSubviews.count > 0 {
            let sep = UIView()
            sep.backgroundColor = UIColor.ainaTextTertiary.withAlphaComponent(0.2)
            sep.translatesAutoresizingMaskIntoConstraints = false
            sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            productRowsStack.addArrangedSubview(sep)
        }

        let row = UIView()
        row.backgroundColor = .clear
        row.translatesAutoresizingMaskIntoConstraints = false

        // SF Symbol icon
        let symbolName = isAdded ? "plus.circle.fill" : "minus.circle.fill"
        let iconColor   = isAdded ? UIColor.ainaSageGreen : UIColor.ainaSoftRed
        let iconConfig  = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: iconConfig))
        icon.tintColor = iconColor
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.setContentHuggingPriority(.required, for: .horizontal)

        // Text stack
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .ainaTextPrimary

        let subLabel = UILabel()
        subLabel.text = isAdded ? "Added this week" : "Removed this week"
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = .ainaTextSecondary

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // Remove button
        let removeBtn = UIButton(type: .system)
        let trashConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        removeBtn.setImage(UIImage(systemName: "xmark", withConfiguration: trashConfig), for: .normal)
        removeBtn.tintColor = UIColor.ainaTextTertiary
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        removeBtn.setContentHuggingPriority(.required, for: .horizontal)
        removeBtn.tag = productChanges.count - 1
        removeBtn.addTarget(self, action: #selector(removeRow(_:)), for: .touchUpInside)

        row.addSubview(icon)
        row.addSubview(textStack)
        row.addSubview(removeBtn)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 4),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: removeBtn.leadingAnchor, constant: -8),

            removeBtn.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -4),
            removeBtn.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        productRowsStack.addArrangedSubview(row)
        onProductChangesUpdated?(productChanges)
    }

    @objc private func removeRow(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < productChanges.count else { return }
        productChanges.remove(at: idx)

        // Each row after the first has a separator view before it.
        // Stack layout: row0, sep, row1, sep, row2 …
        // Stack index of rowN = N == 0 ? 0 : N*2-1 (sep) + 1 = N*2
        // Simpler: remove the view whose button tag matches, plus the adjacent separator.
        let allViews = productRowsStack.arrangedSubviews
        if let rowView = allViews.first(where: { $0.subviews.contains(sender) }) {
            if let rowIdx = allViews.firstIndex(of: rowView) {
                // Remove preceding separator if present
                if rowIdx > 0 {
                    let sep = allViews[rowIdx - 1]
                    productRowsStack.removeArrangedSubview(sep)
                    sep.removeFromSuperview()
                }
            }
            productRowsStack.removeArrangedSubview(rowView)
            rowView.removeFromSuperview()
        }

        // Re-tag remaining remove buttons
        var tagIdx = 0
        for view in productRowsStack.arrangedSubviews {
            if let btn = view.subviews.compactMap({ $0 as? UIButton }).first {
                btn.tag = tagIdx
                tagIdx += 1
            }
        }
        onProductChangesUpdated?(productChanges)
    }
}
