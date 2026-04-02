import UIKit

class ProfileViewController: UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource {

@IBOutlet weak var ProfileCollectionView: UICollectionView!

private var userProfile: UserProfile? { AppDataModel.shared.userProfile }

override func viewDidLoad() {
super.viewDidLoad()

title = "Profile"

// Background Theme
view.applyAINABackground()
view.backgroundColor = .clear

// Settings Button
navigationItem.rightBarButtonItem = UIBarButtonItem(
    image: UIImage(systemName: "gearshape.fill"),
    style: .plain,
    target: self,
    action: #selector(openSettings)
)
navigationItem.rightBarButtonItem?.tintColor = .primarypink

ProfileCollectionView.delegate = self
ProfileCollectionView.dataSource = self
ProfileCollectionView.backgroundColor = .clear

registerCells()
ProfileCollectionView.collectionViewLayout = createLayout()


}

// MARK: - Navigation

@objc private func openSettings() {
let vc = SettingsViewController()
vc.hidesBottomBarWhenPushed = true
navigationController?.pushViewController(vc, animated: true)
}

// MARK: - Register Cells

private func registerCells() {
ProfileCollectionView.register(
UINib(nibName: "ProfileCollectionViewCell", bundle: nil),
forCellWithReuseIdentifier: "ProfileCell"
)

ProfileCollectionView.register(
    UINib(nibName: "SkinProfileCollectionViewCell", bundle: nil),
    forCellWithReuseIdentifier: "SkinProfileCell"
)

ProfileCollectionView.register(
    UINib(nibName: "SectionHeaderReusableView", bundle: nil),
    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
    withReuseIdentifier: SectionHeaderReusableView.identifier
)


}

// MARK: - Sections

func numberOfSections(in collectionView: UICollectionView) -> Int {
return 2
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
    let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "ProfileCell",
        for: indexPath
    ) as! ProfileCollectionViewCell

    cell.nameLabel.text = userProfile?.name ?? "Shreya"
    cell.ageLabel.text = " 17 years  "
//    cell.daysLabel.text = "23"
//    cell.JournalLabel.text = "17"

    return cell

case 1:
    let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "SkinProfileCell",
        for: indexPath
    ) as! SkinProfileCollectionViewCell

    cell.onItemSelected = { [weak self] index in
        guard let self = self else { return }

        switch index {
        case 0: self.navigateTo(ProfileSkinTypeViewController())
        case 1: self.navigateTo(ProfileConcernsViewController())
        case 2: self.navigateTo(ProfileSensitivityViewController())
        case 3: self.navigateTo(ProfileGoalsViewController())
        case 4: self.navigateTo(SavedRoutinesViewController())
        default: break
        }
    }

    return cell

default:
    return UICollectionViewCell()
}


}

// MARK: - Header

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
header.titleLabel.text = indexPath.section == 1 ? "SKIN PROFILE" : ""

return header

}

// MARK: - Layout

private func createLayout() -> UICollectionViewLayout {

return UICollectionViewCompositionalLayout { sectionIndex, _ in

    let sectionHeights: [Int: CGFloat] = [
        0: 140,   // Profile Card
        1: 300    // Skin Profile
    ]

    let height = sectionHeights[sectionIndex] ?? 250

    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(height)
    )

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let group = NSCollectionLayoutGroup.vertical(
        layoutSize: itemSize,
        subitems: [item]
    )

    let section = NSCollectionLayoutSection(group: group)

    section.contentInsets = NSDirectionalEdgeInsets(
        top: sectionIndex == 0 ? 12 : 16,
        leading: 16,
        bottom: 8,
        trailing: 16
    )

    if sectionIndex != 0 {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(40)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
    }

    return section
}


}

// MARK: - Navigation Helper

private func navigateTo(_ vc: UIViewController) {
vc.hidesBottomBarWhenPushed = true
navigationController?.pushViewController(vc, animated: true)
}

}
