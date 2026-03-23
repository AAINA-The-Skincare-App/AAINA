import UIKit

class IngredientDetailUI {

    let scrollView = UIScrollView()
    let stack = UIStackView()
    let closeButton = UIButton(type: .system)

    func build(in view: UIView, ingredient: Ingredient) {

        // MARK: - Stack config
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - ScrollView config
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        // MARK: - Hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        scrollView.contentInsetAdjustmentBehavior = .automatic

        // MARK: - Constraints (FIXED )
        NSLayoutConstraint.activate([

            // ScrollView fills screen
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Stack inside scrollView (IMPORTANT: contentLayoutGuide)
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // THIS LINE MAKES SCROLL WORK
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        // MARK: - Build Sections
        buildHeader(ingredient)
        buildTags(ingredient)
        buildDescription(ingredient)
        buildWhatItDoes(ingredient)
        buildBestFor(ingredient)
        buildInfoCards(ingredient)
        buildCombinesWith(ingredient)
        buildAvoidWith(ingredient)

        // Bottom spacing
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stack.addArrangedSubview(spacer)
    }
}



extension IngredientDetailUI {

    private func buildHeader(_ ingredient: Ingredient) {

        let title = UILabel()
        title.text = ingredient.name
        title.font = .systemFont(ofSize: 34, weight: .bold)

        let scientific = UILabel()
        scientific.text = ingredient.scientificName
        scientific.font = .italicSystemFont(ofSize: 16)
        scientific.textColor = .tertiaryLabel

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.backgroundColor = .systemGray6
        closeButton.layer.cornerRadius = 18
        closeButton.tintColor = .label

        let container = UIView()

        container.addSubview(title)
        container.addSubview(scientific)
        container.addSubview(closeButton)

        title.translatesAutoresizingMaskIntoConstraints = false
        scientific.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            title.topAnchor.constraint(equalTo: container.topAnchor),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            scientific.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            scientific.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scientific.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        stack.addArrangedSubview(container)
    }
}



extension IngredientDetailUI {
    private func buildTags(_ ingredient: Ingredient) {
        
        guard let tags = ingredient.tags else { return }
        
        // MARK: ScrollView (NEW)
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: Stack
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.spacing = 10
        tagStack.translatesAutoresizingMaskIntoConstraints = false
        
        scroll.addSubview(tagStack)
        
        NSLayoutConstraint.activate([
            tagStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            tagStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            tagStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            tagStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            
            tagStack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])
        
        // MARK: Pills
        for tag in tags {
            
            let pill = PaddingLabel()
            pill.text = tag.capitalized
            pill.font = .systemFont(ofSize: 13, weight: .medium)
            pill.textAlignment = .center   // IMPROVED
            
            pill.backgroundColor = .systemGray6
            pill.layer.cornerRadius = 16
            pill.layer.masksToBounds = true
            
            pill.padding = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            
            tagStack.addArrangedSubview(pill)
        }
        
        stack.addArrangedSubview(scroll)
        
        // MARK: Height constraint (IMPORTANT)
        scroll.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}


extension IngredientDetailUI {

    private func buildDescription(_ ingredient: Ingredient) {

        let label = UILabel()
        label.text = ingredient.shortDescription
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel

        stack.addArrangedSubview(label)
    }
}


extension IngredientDetailUI {

    private func buildWhatItDoes(_ ingredient: Ingredient) {

        guard let items = ingredient.whatDoesItDo else { return }

        let title = makeSectionTitle("What It Does")

        let card = IngredientCardView()

        for item in items {

            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12

            let icon = makeIcon("checkmark.circle.fill", color: .systemGreen)

            let label = UILabel()
            label.text = item
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)

            row.addArrangedSubview(icon)
            row.addArrangedSubview(label)

            card.stack.addArrangedSubview(row)
        }

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(card)
    }
}

extension IngredientDetailUI {

    private func buildBestFor(_ ingredient: Ingredient) {

        guard let list = ingredient.bestFor else { return }

        let title = UILabel()
        title.text = "Best For"
        title.font = .systemFont(ofSize: 20, weight: .semibold)

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10

        var row: UIStackView?

        for (index,item) in list.enumerated() {

            if index % 2 == 0 {

                row = UIStackView()
                row?.axis = .horizontal
                row?.spacing = 10
                row?.distribution = .fillEqually

                container.addArrangedSubview(row!)
            }
            let pill = PaddingLabel()
            pill.text = item
            pill.font = .systemFont(ofSize: 15, weight: .medium)
            pill.textAlignment = .center   // THIS LINE FIXES IT

            pill.backgroundColor = .systemGray6
            pill.layer.cornerRadius = 16
            pill.layer.masksToBounds = true
            pill.padding = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

            row?.addArrangedSubview(pill)
        }

        if list.count % 2 != 0 {
            let spacer = UIView()
            row?.addArrangedSubview(spacer)
        }

        let section = UIStackView(arrangedSubviews: [title, container])
        section.axis = .vertical
        section.spacing = 10

        stack.addArrangedSubview(section)
    }
}

extension IngredientDetailUI {

    private func buildInfoCards(_ ingredient: Ingredient) {

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16

        if let when = ingredient.whenToUse {

            let icon = makeIcon("clock", color: .systemBlue)
            let card = IngredientCardView(iconView: icon)

            card.setTitle("When to Use")
            card.setText(formatTimeText(when)) // conversion applied

            container.addArrangedSubview(card)
        }

        if let min = ingredient.minConcentration,
           let max = ingredient.maxConcentration {

            let icon = makeIcon("flask", color: .systemBlue)
            let card = IngredientCardView(iconView: icon)

            card.setTitle("Concentration")
            card.setText("\(min)% – \(max)%")

            container.addArrangedSubview(card)
        }

        stack.addArrangedSubview(container)
    }
}

extension IngredientDetailUI {

    private func buildCombinesWith(_ ingredient: Ingredient) {

        guard let list = ingredient.combinesWith, !list.isEmpty else { return }

        let icon = makeIcon("checkmark.circle", color: .systemGreen)
        let card = IngredientCardView(iconView: icon)

        card.setTitle("Combines Well With")

        for item in list {
            
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .top   // IMPORTANT (not baseline)

            // MARK: Dot Container (FIX)
            let dotContainer = UIView()
            dotContainer.translatesAutoresizingMaskIntoConstraints = false
            dotContainer.widthAnchor.constraint(equalToConstant: 16).isActive = true

            let dot = UIView()
            dot.backgroundColor = .systemGreen
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false

            dotContainer.addSubview(dot)

            //  Center dot relative to text top
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8),

                dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor),

                
                dot.topAnchor.constraint(equalTo: dotContainer.topAnchor, constant: 6)
            ])

            // MARK: Label
            let label = UILabel()
            label.text = item
            label.font = .systemFont(ofSize: 15)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0

            // MARK: Add views
            row.addArrangedSubview(dotContainer)
            row.addArrangedSubview(label)

            card.stack.addArrangedSubview(row)
        }

        stack.addArrangedSubview(card)
    }
}

extension IngredientDetailUI {

    private func buildAvoidWith(_ ingredient: Ingredient) {

        guard let list = ingredient.avoidWith else { return }

        let icon = makeIcon("exclamationmark.triangle", color: .systemRed)
        let card = IngredientCardView(iconView: icon)

        card.setTitle("Avoid Combining With")

        if list.isEmpty {
            card.setText("None – Very stable ingredient")
        } else {
            card.setText(list.joined(separator: "\n"))
        }

        stack.addArrangedSubview(card)
    }
}

extension IngredientDetailUI {

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }

    private func makeIcon(_ name: String, color: UIColor) -> UIView {

        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 20

        let icon = UIImageView(image: UIImage(systemName: name))
        icon.tintColor = color
        icon.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 40),
            container.heightAnchor.constraint(equalToConstant: 40),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    // TIME FORMATTER
    private func formatTimeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "AM", with: "Morning")
            .replacingOccurrences(of: "PM", with: "Evening")
    }
}
