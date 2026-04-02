import UIKit

class SettingsViewController: UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource {


private var collectionView: UICollectionView!

override func viewDidLoad() {
    super.viewDidLoad()

    title = "Settings"

    // 🌸 Background (same as profile)
    view.applyAINABackground()
    view.backgroundColor = .clear

    navigationController?.navigationBar.tintColor = .systemPink

    setupCollectionView()
    registerCells()
}

// MARK: - Setup CollectionView

private func setupCollectionView() {
    collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    )

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .clear

    view.addSubview(collectionView)

    NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}

// MARK: - Register Cells

private func registerCells() {

    collectionView.register(
        UINib(nibName: "SpreadCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "SpreadCell"
    )

    collectionView.register(
        UINib(nibName: "ReachCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "ReachCell"
    )

    collectionView.register(
        UINib(nibName: "LegalCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "LegalCell"
    )

    collectionView.register(
        UINib(nibName: "SettingsCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "SettingsCell"
    )

    collectionView.register(
        UINib(nibName: "SectionHeaderReusableView", bundle: nil),
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: SectionHeaderReusableView.identifier
    )
}

// MARK: - Sections

func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 4
}

func collectionView(_ collectionView: UICollectionView,
                    numberOfItemsInSection section: Int) -> Int {
    return 1
}

// MARK: - Cells

func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath)
-> UICollectionViewCell {

    switch indexPath.section {

    case 0:
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "SpreadCell",
            for: indexPath
        )

    case 1:
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "ReachCell",
            for: indexPath
        )

    case 2:
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "LegalCell",
            for: indexPath
        )

    case 3:
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "SettingsCell",
            for: indexPath
        )

    default:
        return UICollectionViewCell()
    }
}

// MARK: - Headers

func collectionView(_ collectionView: UICollectionView,
                    viewForSupplementaryElementOfKind kind: String,
                    at indexPath: IndexPath)
-> UICollectionReusableView {

    let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: SectionHeaderReusableView.identifier,
        for: indexPath
    ) as! SectionHeaderReusableView

    header.titleLabel.textColor = .systemGray
    header.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

    switch indexPath.section {
    case 0: header.titleLabel.text = "SPREAD THE LOVE"
    case 1: header.titleLabel.text = "REACH US"
    case 2: header.titleLabel.text = "LEGAL"
    case 3: header.titleLabel.text = "SETTINGS"
    default: header.titleLabel.text = ""
    }

    return header
}

// MARK: - Layout

private func createLayout() -> UICollectionViewLayout {

    return UICollectionViewCompositionalLayout { sectionIndex, _ in

        let height: CGFloat = sectionIndex == 0 ? 240 : 150

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)

        // ✨ spacing like your UI
        section.contentInsets = NSDirectionalEdgeInsets(
            top: sectionIndex == 0 ? 20 : 16,
            leading: 16,
            bottom: 8,
            trailing: 16
        )

        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]

        return section
    }
}


}
