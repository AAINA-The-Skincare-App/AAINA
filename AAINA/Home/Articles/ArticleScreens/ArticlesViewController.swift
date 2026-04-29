import UIKit

final class ArticlesViewController: UIViewController {

    enum ArticleItem {
        case hero
        case badges([String])
        case heading(String)
        case intro(ArticleSection)
        case gridCards([ArticleCardItem])
        case timeline([ArticleTimelineStep])
        case info(ArticleCardItem, Bool)
        case sources([ArticleSource])
        case empty
    }

    var articleID: String = ""
    var articleTitle: String = ""
    var articleImageName: String = ""
    var articleReadTime: String = ""

    private var article: ArticleContent?
    private var items: [ArticleItem] = []

    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = .white
        view.applyAINABackground()
        article = ArticleStore.article(withID: articleID)
        buildItems()
        setupTopBar()
        setupCollectionView()
        registerCells()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func buildItems() {
        guard let article else {
            items = [.hero, .empty]
            return
        }

        items = [.hero, .badges(article.headerBadges)]
        article.sections.forEach { section in
            items.append(.heading(displayHeading(section.heading)))
            switch section.type {
            case .introCard:
                items.append(.intro(section))
            case .gridCards:
                items.append(.gridCards(section.items ?? []))
            case .timeline:
                items.append(.timeline(section.steps ?? []))
            case .infoGroup:
                if let alert = section.alertBox {
                    items.append(.info(alert, true))
                }
                items.append(contentsOf: (section.bottomCards ?? []).map { .info($0, false) })
            case .sourcesList:
                items.append(.sources(section.sources ?? []))
            }
        }
    }

    private func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)

        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        backButton.layer.cornerRadius = 22
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.ainaTextPrimary
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)

        titleLabel.text = articleTitle
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.ainaTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 72),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 18),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -72),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
    }

    @objc private func handleBackTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 18
        flowLayout.minimumInteritemSpacing = 14
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func registerCells() {
        collectionView.register(UINib(nibName: ArticleHeroCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleHeroCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleBadgesCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleBadgesCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleIntroCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleIntroCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleGridCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleGridCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleGridCardsCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleGridCardsCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleTimelineCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleTimelineCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleInfoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleInfoCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleSourcesCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleSourcesCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ArticleEmptyCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticleEmptyCollectionViewCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HeadingCell")
    }
}

extension ArticlesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.item] {
        case .hero:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleHeroCollectionViewCell.identifier, for: indexPath) as! ArticleHeroCollectionViewCell
            cell.configure(imageName: articleImageName, readTime: article?.readTime ?? articleReadTime)
            return cell
        case .badges(let badges):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleBadgesCollectionViewCell.identifier, for: indexPath) as! ArticleBadgesCollectionViewCell
            cell.configure(badges: badges.filter { !$0.localizedCaseInsensitiveContains("read") })
            return cell
        case .heading(let title):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadingCell", for: indexPath)
            configureHeadingCell(cell, title: title)
            return cell
        case .intro(let section):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleIntroCollectionViewCell.identifier, for: indexPath) as! ArticleIntroCollectionViewCell
            cell.configure(section: section)
            return cell
        case .gridCards(let cards):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleGridCardsCollectionViewCell.identifier, for: indexPath) as! ArticleGridCardsCollectionViewCell
            cell.configure(items: cards)
            return cell
        case .timeline(let steps):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleTimelineCollectionViewCell.identifier, for: indexPath) as! ArticleTimelineCollectionViewCell
            cell.configure(steps: steps)
            return cell
        case .info(let item, let isWarning):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleInfoCollectionViewCell.identifier, for: indexPath) as! ArticleInfoCollectionViewCell
            cell.configure(item: item, isWarning: isWarning)
            return cell
        case .sources(let sources):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleSourcesCollectionViewCell.identifier, for: indexPath) as! ArticleSourcesCollectionViewCell
            cell.configure(sources: sources)
            return cell
        case .empty:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleEmptyCollectionViewCell.identifier, for: indexPath) as! ArticleEmptyCollectionViewCell
            cell.configure()
            return cell
        }
    }

    private func configureHeadingCell(_ cell: UICollectionViewCell, title: String) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor.ainaTextPrimary
        cell.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
    }
}

extension ArticlesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 26, bottom: 28, right: 26)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.bounds.width - 52
        switch items[indexPath.item] {
        case .hero:
            return CGSize(width: fullWidth, height: 360)
        case .badges:
            return CGSize(width: fullWidth, height: 38)
        case .heading:
            return CGSize(width: fullWidth, height: 34)
        case .intro(let section):
            return CGSize(width: fullWidth, height: introHeight(for: section, width: fullWidth))
        case .gridCards(let cards):
            return CGSize(width: fullWidth, height: gridCardsHeight(for: cards))
        case .timeline(let steps):
            return CGSize(width: fullWidth, height: timelineHeight(for: steps, width: fullWidth))
        case .info(_, let isWarning):
            return CGSize(width: fullWidth, height: isWarning ? 140 : 112)
        case .sources:
            return CGSize(width: fullWidth, height: 42)
        case .empty:
            return CGSize(width: fullWidth, height: 170)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        18
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        14
    }
}

private extension ArticlesViewController {
    func introHeight(for section: ArticleSection, width: CGFloat) -> CGFloat {
        let bodyWidth = width - 48
        let bodyHeight = textHeight(
            section.content ?? "",
            font: .systemFont(ofSize: 15, weight: .regular),
            width: bodyWidth
        )
        let hasPills = !(section.pills ?? []).isEmpty
        let pillsHeight: CGFloat = hasPills ? 24 : 0
        let spacing: CGFloat = hasPills ? 18 : 0
        let height = 20 + bodyHeight + spacing + pillsHeight + 20
        return min(max(ceil(height), hasPills ? 132 : 96), 220)
    }

    func gridCardsHeight(for cards: [ArticleCardItem]) -> CGFloat {
        let textWidth: CGFloat = 146
        let maxTextHeight = cards.map { card in
            let titleHeight = textHeight(
                card.title,
                font: .systemFont(ofSize: 15, weight: .semibold),
                width: textWidth
            )
            let descriptionHeight = textHeight(
                card.description,
                font: .systemFont(ofSize: 13, weight: .regular),
                width: textWidth
            )
            return titleHeight + 7 + descriptionHeight
        }.max() ?? 52

        return max(ceil(maxTextHeight + 36), 102)
    }

    func timelineHeight(for steps: [ArticleTimelineStep], width: CGFloat) -> CGFloat {
        guard !steps.isEmpty else { return 96 }
        let textWidth = width - 28 - 16 - 18 - 28
        let rowHeights = steps.map { step in
            let labelHeight = textHeight(
                step.label,
                font: .systemFont(ofSize: 14, weight: .semibold),
                width: textWidth
            ) + 6
            let bodyHeight = textHeight(
                step.text,
                font: .systemFont(ofSize: 15, weight: .regular),
                width: textWidth
            )
            return max(24, labelHeight + 8 + bodyHeight)
        }
        let spacing = CGFloat(max(steps.count - 1, 0)) * 20
        return ceil(28 + rowHeights.reduce(0, +) + spacing + 28)
    }

    func textHeight(_ text: String, font: UIFont, width: CGFloat, maximumLines: Int = 0) -> CGFloat {
        guard !text.isEmpty else { return 0 }
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = (text as NSString).boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let measuredHeight = ceil(rect.height)

        if maximumLines > 0 {
            return min(measuredHeight, ceil(font.lineHeight * CGFloat(maximumLines)))
        }

        return measuredHeight
    }

    func displayHeading(_ heading: String) -> String {
        heading
            .lowercased()
            .split(separator: " ")
            .map { word in
                ["spf", "aad", "nih"].contains(word.lowercased()) ? word.uppercased() : word.capitalized
            }
            .joined(separator: " ")
    }
}
