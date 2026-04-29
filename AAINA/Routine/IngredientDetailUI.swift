import UIKit

class IngredientDetailUI {

    let scrollView = UIScrollView()
    let stack = UIStackView()
    let closeButton = UIButton(type: .system)

    func build(in view: UIView, ingredient: Ingredient) {

            //  Background
            view.backgroundColor = .clear
            view.applyAINABackground()

            // MARK: Stack
            stack.axis = .vertical
            stack.spacing = 24
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.backgroundColor = .clear

            // MARK: ScrollView
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.alwaysBounceVertical = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .clear

            // MARK: Hierarchy
            view.addSubview(scrollView)
            scrollView.addSubview(stack)

            //  ADD BLOBS (correct layering)
            addBlobs(to: view)

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

    private func addBlobs(to view: UIView) {

        let topRight = makeBlob(size: 260, color: .ainaCoralPink,  alpha: 0.38)
        let midLeft  = makeBlob(size: 220, color: .ainaDustyRose,  alpha: 0.28)
        let bottomR  = makeBlob(size: 300, color: .ainaLightBlush, alpha: 0.45)

        for blob in [bottomR, midLeft, topRight] {
            view.insertSubview(blob, belowSubview: scrollView)
        }

        NSLayoutConstraint.activate([
            topRight.topAnchor.constraint(equalTo: view.topAnchor, constant: -40),
            topRight.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),
            topRight.widthAnchor.constraint(equalToConstant: 260),
            topRight.heightAnchor.constraint(equalToConstant: 260),

            midLeft.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            midLeft.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            midLeft.widthAnchor.constraint(equalToConstant: 220),
            midLeft.heightAnchor.constraint(equalToConstant: 220),

            bottomR.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100),
            bottomR.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),
            bottomR.widthAnchor.constraint(equalToConstant: 300),
            bottomR.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
}
// MARK: - BLOB VIEW

private func makeBlob(size: CGFloat, color: UIColor, alpha: CGFloat) -> UIView {

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

extension IngredientDetailUI {

    private func buildHeader(_ ingredient: Ingredient) {

        // ── Close button (top-right, small) ───────────────────────────
        let btnSize: CGFloat = 28
        closeButton.setImage(
            UIImage(systemName: "xmark")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)),
            for: .normal
        )
        closeButton.backgroundColor = UIColor.ainaGlassElevated
        closeButton.tintColor = .ainaTextPrimary
        closeButton.layer.cornerRadius = btnSize / 2
        closeButton.layer.masksToBounds = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: btnSize),
            closeButton.heightAnchor.constraint(equalToConstant: btnSize)
        ])

        // ── Title (large, bold, centered) ────────────────────────────
        let title = UILabel()
        title.text = ingredient.name
        title.font = .systemFont(ofSize: 34, weight: .bold)
        title.textColor = .ainaTextPrimary
        title.textAlignment = .left
        title.numberOfLines = 0

        // ── Scientific name (italic, left, muted) ─────────────────────
        let scientific = UILabel()
        scientific.text = ingredient.scientificName
        scientific.font = .italicSystemFont(ofSize: 16)
        scientific.textColor = .tertiaryLabel
        scientific.textAlignment = .left

        // ── Close button row (right-aligned) ──────────────────────────
        let btnRow = UIView()
        btnRow.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: btnRow.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: btnRow.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: btnRow.bottomAnchor)
        ])

        // ── Vertical stack: close row / title / scientific ────────────
        let container = UIStackView(arrangedSubviews: [btnRow, title, scientific])
        container.axis = .vertical
        container.spacing = 6
        container.setCustomSpacing(12, after: btnRow)

        stack.addArrangedSubview(container)
    }
}



extension IngredientDetailUI {
    private func buildTags(_ ingredient: Ingredient) {

        guard let tags = ingredient.tags else { return }

     
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        scroll.translatesAutoresizingMaskIntoConstraints = false

    
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

            pill.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.12)
            pill.textColor = UIColor.ainaDustyRose
            pill.layer.cornerRadius = 16
            pill.layer.masksToBounds = true
            pill.layer.borderWidth = 1.2
            pill.layer.borderColor = UIColor.ainaDustyRose.withAlphaComponent(0.30).cgColor

            pill.padding = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)

            tagStack.addArrangedSubview(pill)
        }

        stack.addArrangedSubview(scroll)

        scroll.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}


extension IngredientDetailUI {

    private func buildDescription(_ ingredient: Ingredient) {

        let label = UILabel()
        label.text = ingredient.shortDescription
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ainaTextSecondary
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
            row.alignment = .center

            let icon = makeIcon("checkmark.circle.fill", color: .ainaCoralPink)

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
        container.spacing = 12

        var row: UIStackView?

        for (index, item) in list.enumerated() {

            if index % 2 == 0 {
                row = UIStackView()
                row?.axis = .horizontal
                row?.spacing = 10
                row?.alignment = .fill
                row?.distribution = .fillEqually
                container.addArrangedSubview(row!)
            }

            // Shadow wrapper (masksToBounds=false so shadow is visible)
            let shadow = UIView()
            shadow.backgroundColor = .clear
            shadow.layer.shadowColor = UIColor.ainaDustyRose.withAlphaComponent(0.22).cgColor
            shadow.layer.shadowOpacity = 1
            shadow.layer.shadowRadius = 6
            shadow.layer.shadowOffset = CGSize(width: 0, height: 2)

            // Pill inside wrapper (masksToBounds=true clips corners properly)
            let pill = PaddingLabel()
            pill.text = item
            pill.font = .systemFont(ofSize: 15, weight: .medium)
            pill.textAlignment = .center
            pill.numberOfLines = 0
            pill.textColor = UIColor.ainaDustyRose
            pill.backgroundColor = UIColor.ainaDustyRose.withAlphaComponent(0.12)
            pill.layer.cornerRadius = 20
            pill.layer.cornerCurve = .continuous
            pill.layer.masksToBounds = true
            pill.layer.borderWidth = 1.2
            pill.layer.borderColor = UIColor.ainaDustyRose.withAlphaComponent(0.30).cgColor
            pill.translatesAutoresizingMaskIntoConstraints = false
            pill.padding = UIEdgeInsets(top: 11, left: 18, bottom: 11, right: 18)

            shadow.addSubview(pill)
            NSLayoutConstraint.activate([
                pill.topAnchor.constraint(equalTo: shadow.topAnchor),
                pill.bottomAnchor.constraint(equalTo: shadow.bottomAnchor),
                pill.leadingAnchor.constraint(equalTo: shadow.leadingAnchor),
                pill.trailingAnchor.constraint(equalTo: shadow.trailingAnchor),
            ])

            row?.addArrangedSubview(shadow)
        }

        // Balance last row if odd number of pills
        if list.count % 2 != 0, let lastRow = container.arrangedSubviews.last as? UIStackView {
            let spacer = UIView()
            spacer.backgroundColor = .clear
            lastRow.addArrangedSubview(spacer)
        }

        let section = UIStackView(arrangedSubviews: [title, container])
        section.axis = .vertical
        section.spacing = 14

        stack.addArrangedSubview(section)
    }
}

extension IngredientDetailUI {

    private func buildInfoCards(_ ingredient: Ingredient) {

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16

        if let when = ingredient.whenToUse {

            let icon = makeIcon("clock", color: .ainaCoralPink)
            let card = IngredientCardView(iconView: icon)

            card.setTitle("When to Use")
            card.setText(formatTimeText(when)) // conversion applied

            container.addArrangedSubview(card)
        }

        if let min = ingredient.minConcentration,
           let max = ingredient.maxConcentration {

            let icon = makeIcon("flask", color: .ainaCoralPink)
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

        let icon = makeIcon("checkmark.circle", color: .ainaCoralPink)
        let card = IngredientCardView(iconView: icon)

        card.setTitle("Combines Well With")

        for item in list {

            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .top

            let dotContainer = UIView()
            dotContainer.translatesAutoresizingMaskIntoConstraints = false
            dotContainer.widthAnchor.constraint(equalToConstant: 16).isActive = true

            let dot = UIView()
            dot.backgroundColor = UIColor.ainaCoralPink
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

        let icon = makeIcon("exclamationmark.triangle", color: .ainaSoftRed)
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

   
    private func formatTimeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "AM", with: "Morning")
            .replacingOccurrences(of: "PM", with: "Evening")
    }
}
