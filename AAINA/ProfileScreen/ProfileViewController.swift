import UIKit

class ProfileViewController: UIViewController,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource {

    @IBOutlet weak var ProfileCollectionView: UICollectionView!

    private var userProfile: UserProfile? { AppDataModel.shared.userProfile }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        view.backgroundColor = .systemGray6

        ProfileCollectionView.backgroundColor = .clear
        ProfileCollectionView.delegate = self
        ProfileCollectionView.dataSource = self

        registerCells()
        ProfileCollectionView.collectionViewLayout = createLayout()
    }

    // Register Cells

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
            UINib(nibName: "SpreadCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SpreadCell"
        )

        ProfileCollectionView.register(
            UINib(nibName: "ReachCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ReachCell"
        )

        ProfileCollectionView.register(
            UINib(nibName: "LegalCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "LegalCell"
        )

        ProfileCollectionView.register(
            UINib(nibName: "SettingsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SettingsCell"
        )

        ProfileCollectionView.register(
            UINib(nibName: "SectionHeaderReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderReusableView.identifier
        )
    }

    // Sections

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    // Cells

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        switch indexPath.section {

        // SECTION 0  Profile
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileCell",
                for: indexPath
            ) as! ProfileCollectionViewCell

            cell.nameLabel.text = userProfile?.name ?? "User"
            cell.ageLabel.text = userProfile?.age.map { "\($0) years" } ?? ""
            cell.profileImageView.image = UIImage(systemName: "person.circle.fill")
            cell.profileImageView.tintColor = .systemGray3

            return cell

        // SECTION 1  Skin Profile Card
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SkinProfileCell",
                for: indexPath
            ) as! SkinProfileCollectionViewCell

            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }

                switch index {
                case 0:
                    self.navigateTo(ProfileSkinTypeViewController())
                case 1:
                    self.navigateTo(ProfileConcernsViewController())
                case 2:
                    self.navigateTo(ProfileSensitivityViewController())
                case 3:
                    self.navigateTo(ProfileGoalsViewController())
                case 4:
                    self.navigateTo(SavedRoutinesViewController())
                default:
                    break
                }
            }

            return cell

        // SECTION 2  Spread
        case 2:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SpreadCell",
                for: indexPath
            )

        // SECTION 3  Reach
        case 3:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "ReachCell",
                for: indexPath
            )

        // SECTION 4  Legal
        case 4:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "LegalCell",
                for: indexPath
            )

        // SECTION 5 Settings
        case 5:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SettingsCell",
                for: indexPath
            )

        default:
            return UICollectionViewCell()
        }
    }

    // Header Titles

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath)
    -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderReusableView.identifier,
            for: indexPath
        ) as! SectionHeaderReusableView

        switch indexPath.section {
        case 1:
            header.titleLabel.text = "SKIN PROFILE"
        case 2:
            header.titleLabel.text = "SPREAD THE LOVE"
        case 3:
            header.titleLabel.text = "REACH US"
        case 4:
            header.titleLabel.text = "LEGAL"
        case 5:
            header.titleLabel.text = "SETTINGS"
        default:
            header.titleLabel.text = ""
        }

        return header
    }

    // Navigation

    private func navigateTo(_ viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    // Layout

    private func createLayout() -> UICollectionViewLayout {

        return UICollectionViewCompositionalLayout { sectionIndex, _ in

            let height: CGFloat

            switch sectionIndex {
            case 0: height = 100
            case 1: height = 300
            case 2: height = 240
            case 3, 4, 5: height = 140
            default: height = 100
            }

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

            section.contentInsets = NSDirectionalEdgeInsets(
                top: sectionIndex == 0 ? 20 : 16,
                leading: 16,
                bottom: 16,
                trailing: 16
            )

            if sectionIndex != 0 {

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
            }

            return section
        }
    }
}
