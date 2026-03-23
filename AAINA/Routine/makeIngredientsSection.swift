////
//  makeIngredientsSection.swift
//  ro
//

//
//  makeIngredientsSection.swift
//  ro
//

import UIKit

extension RoutineDetailViewController {

    func makeIngredientsSection(_ ingredients: [Ingredient]) -> UIView {

        let container = UIView()

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10

        var currentRow: UIStackView?

        for (index, ingredient) in ingredients.enumerated() {

            if index % 2 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 10
                currentRow?.distribution = .fillEqually

                if let row = currentRow {
                    grid.addArrangedSubview(row)
                }
            }

            // Pill
            let pill = PaddingLabel()
            pill.text = ingredient.name
            pill.textAlignment = .center
            pill.font = .systemFont(ofSize: 14, weight: .medium)

            pill.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            pill.textColor = .systemBlue

            pill.layer.cornerRadius = 16
            pill.layer.masksToBounds = true
            pill.padding = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)

            // IMPORTANT: store ingredient ID
            pill.accessibilityIdentifier = ingredient.id
            pill.isUserInteractionEnabled = true

            // Tap gesture
            let tap = UITapGestureRecognizer(target: self, action: #selector(openIngredient(_:)))
            pill.addGestureRecognizer(tap)

            currentRow?.addArrangedSubview(pill)
        }

        container.addSubview(grid)
        grid.pinEdges(to: container, padding: 0)

        return container
    }
}
