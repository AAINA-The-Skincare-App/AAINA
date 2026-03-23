import UIKit
import AVKit

class RoutineDetailViewController: UIViewController {

    var step: RoutineStep?
    var aiStep: AIRoutineStep?
    var dataModel: DataModel!

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = "Routine"

        setupLayout()
        buildUI()
    }
}
extension RoutineDetailViewController {

    @objc func openIngredient(_ sender: UITapGestureRecognizer) {

        guard let pill = sender.view as? PaddingLabel,
              let id = pill.accessibilityIdentifier else { return }

        print("Tapped ingredient ID:", id)
        guard let ingredient = dataModel.ingredient(for: id)
        else {

            let alert = UIAlertController(
                title: "Ingredient not found",
                message: id,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)

            return
        }
        

        print(" Opening ingredient:", ingredient.name)

        let vc = IngredientDetailViewController(ingredient: ingredient)
        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }
}
// MARK: Layout Setup

extension RoutineDetailViewController {

    private func setupLayout() {

        contentStack.axis = .vertical
        contentStack.spacing = 24

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            //  SCROLL VIEW (now starts below navigation bar)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            //  CONTENT
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            //  IMPORTANT (for proper scrolling)
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
}

extension RoutineDetailViewController {

    private func makeVideoCard() -> UIView {

        let card = makeCard()
        card.backgroundColor = .black
        card.clipsToBounds = true

        guard let url = Bundle.main.url(forResource: "Cleanser", withExtension: "mp4") else {
            card.heightAnchor.constraint(equalToConstant: 220).isActive = true
            return card
        }

        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.showsPlaybackControls = true
        playerVC.videoGravity = .resizeAspectFill

        addChild(playerVC)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 220),
            playerVC.view.topAnchor.constraint(equalTo: card.topAnchor),
            playerVC.view.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            playerVC.view.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            playerVC.view.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])

        return card
    }
}

// MARK: Description

extension RoutineDetailViewController {

    private func makeDescriptionSection() -> UIView {

        let container = UIView()
        let title = UILabel()
        title.text = "Description"
        title.font = .systemFont(ofSize: 17, weight: .semibold)


        let text = UILabel()
        text.numberOfLines = 0
        text.font = .systemFont(ofSize: 15)
        text.textColor = .secondaryLabel
        text.text = aiStep?.reason ?? step?.productDescription ?? ""

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [text, divider])
        stack.axis = .vertical
        stack.spacing = 22
        container.addSubview(stack)
        stack.pinEdges(to: container, padding: 0)

        return container
    }
}

// MARK: Instruction

extension RoutineDetailViewController {

    private func makeInstructionSection() -> UIView {

        let container = UIView()

        let title = UILabel()
        title.text = "Instruction"
        title.font = .systemFont(ofSize: 17, weight: .semibold)

        let text = UILabel()
        text.numberOfLines = 0
        text.font = .systemFont(ofSize: 15)
        text.textColor = .secondaryLabel
        text.text = aiStep?.usage ?? step?.instructionText ?? ""

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [title, text, divider])
        stack.axis = .vertical
        stack.spacing = 21

        container.addSubview(stack)
        stack.pinEdges(to: container, padding: 0)

        return container
    }
}

// MARK: Ingredients

extension RoutineDetailViewController {
    
    private func makeIngredientsSection() -> UIView {

        let container = UIView()

        let title = UILabel()
        title.text = "Key Ingredients"
        title.font = .systemFont(ofSize: 17, weight: .semibold)

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12

        // Build (name, ingredientID?) pairs — ID present = tappable
        var pillData: [(name: String, id: String?)] = []

        if let ai = aiStep {
            pillData = ai.keyIngredients.map { name in
                (name: name, id: dataModel.matchIngredient(name: name)?.id)
            }
        } else if let step = step {
            let names = dataModel.ingredientNames(for: step)
            pillData = zip(names, step.ingredientIDs).map { (name: $0, id: $1) }
        }

        var row: UIStackView?

        for (index, item) in pillData.enumerated() {

            if index % 2 == 0 {
                row = UIStackView()
                row!.axis = .horizontal
                row!.spacing = 12
                row!.distribution = .fillEqually
                grid.addArrangedSubview(row!)
            }

            let pill = PaddingLabel()
            pill.text = item.name
            pill.textAlignment = .center
            pill.font = .systemFont(ofSize: 14, weight: .medium)
            pill.backgroundColor = .systemGray5
            pill.layer.cornerRadius = 18
            pill.layer.masksToBounds = true
            pill.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

            if let id = item.id {
                pill.textColor = .systemBlue
                pill.isUserInteractionEnabled = true
                pill.accessibilityIdentifier = id
                let tap = UITapGestureRecognizer(target: self, action: #selector(openIngredient(_:)))
                pill.addGestureRecognizer(tap)
            } else {
                pill.textColor = .label
            }

            row?.addArrangedSubview(pill)
        }

        if pillData.count % 2 != 0 {
            row?.addArrangedSubview(UIView())
        }

        let stack = UIStackView(arrangedSubviews: [title, grid])
        stack.axis = .vertical
        stack.spacing = 16

        container.addSubview(stack)
        stack.pinEdges(to: container, padding: 0)

        return container
    }
}

// MARK: Card

extension RoutineDetailViewController {

    private func makeHeader() -> UIView {

        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.textColor = .label.withAlphaComponent(0.6)

        if let ai = aiStep {
            titleLabel.text = ai.productType.rawValue.capitalized
            subtitleLabel.text = ai.productName
        } else {
            titleLabel.text = step?.type.rawValue.capitalized ?? ""
            subtitleLabel.text = step?.stepTitle ?? ""
        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4

        container.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor ),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor ),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor ),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor )
        ])

        return container
    }
}
extension RoutineDetailViewController {

    private func buildUI() {
        contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12)
        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(makeVideoCard())
        contentStack.addArrangedSubview(makeDescriptionSection())
        contentStack.addArrangedSubview(makeInstructionSection())
        contentStack.addArrangedSubview(makeIngredientsSection())
    }

}

// MARK: Helper

extension UIView {

    func pinEdges(to view: UIView, padding: CGFloat) {

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
        ])
    }
}
// MARK: Card

extension RoutineDetailViewController {

    private func makeCard() -> UIView {

        let card = UIView()

        card.backgroundColor = .systemGray5
        card.layer.cornerRadius = 20
        card.clipsToBounds = true

        return card
    }
}
