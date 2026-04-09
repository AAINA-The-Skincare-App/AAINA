//
//  HomeViewController.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    var dataModel: AppDataModel!
    
    //fallback routine when no AI routine exists — for default JSON-backed steps
    private let defaultDataModel = DataModel()
    
    private var selectedSegment: Int = 0
    private var steps: [RoutineStep] = []
    private var aiSteps: [AIRoutineStep] = []
    private var aiOutput: AIRoutineOutput?
    
    private var currentUserID: String {
        defaultDataModel.currentUser().id
    }
    
    private var skinInsights: [SkinInsight] {
        dataModel.skinInsights
    }
    
    func insightStatus(from percent: Int) -> String {
        switch percent {
        case 75...100:
            return "Improving"
        case 50..<75:
            return "Consistent"
        default:
            return "Declined"
        }
    }
    
    
    @IBOutlet weak var HomeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dataModel == nil {
            dataModel = AppDataModel.shared
        }
        
        title = "Home"
        
        view.applyAINABackground()
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ainaTextPrimary
        ]
        
        // Read directly from the singleton — no disk read needed, already loaded at launch
        aiOutput = dataModel.aiRoutine
        
        setupCollectionView()
        registerCells()

        print(dataModel!)

        homeCollectionView.collectionViewLayout = generateLayout()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Re-read from singleton in case it was updated (e.g. user just completed onboarding)
        aiOutput = dataModel.aiRoutine
        reloadRoutineData()
        HomeCollectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 5 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "IngredientScannerViewController") as! IngredientScannerViewController
            vc.dataModel = DataModel()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

        // MARK: - Setup

extension HomeViewController {
    
    private func setupCollectionView() {
        HomeCollectionView.delegate = self
        HomeCollectionView.dataSource = self
        HomeCollectionView.backgroundColor = .clear
        HomeCollectionView.showsVerticalScrollIndicator = false
        HomeCollectionView.alwaysBounceVertical = true
        HomeCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    private func registerCells() {
        HomeCollectionView.register(
            UINib(nibName: "GreetingSectionCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: GreetingSectionCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: "DailyTipCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: DailyTipCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: "HomeRoutineSectionCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: HomeRoutineSectionCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: "InsightSectionCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: InsightSectionCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: SkinMatrixSectionCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: SkinMatrixSectionCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: IngredientScannerCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: IngredientScannerCollectionViewCell.identifier
        )
        
        HomeCollectionView.register(
            UINib(nibName: "HomeSectionHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeader.identifier
        )
    }
}

        // MARK: - Data

extension HomeViewController {
    
    private func reloadRoutineData() {
        if let ai = aiOutput {
            aiSteps = selectedSegment == 0 ? ai.morning : ai.evening
            steps = []
        } else {
            aiSteps = []
            steps = selectedSegment == 0
            ? defaultDataModel.morningSteps(for: currentUserID)
            : defaultDataModel.eveningSteps(for: currentUserID)
        }
    }
    
    private func currentUserName() -> String {
        return dataModel.userProfile?.name ?? ""
    }
    
    private func currentDailyTipTitle() -> String {
        return dataModel.dailyTip?.tipTitle ?? ""
    }
    
    private func currentDailyTipText() -> String {
        return dataModel.dailyTip?.tipDesc ?? ""
    }
    
    private func currentRoutineTitles() -> [String] {
        if aiOutput != nil {
            return aiSteps.map { $0.productName }
        } else {
            return steps.map { $0.stepTitle }
        }
    }
    
    private func currentCompletedCount() -> Int {
        return 0
    }
}


        // MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 4:
            return skinInsights.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GreetingSectionCollectionViewCell.identifier,
                for: indexPath
            ) as! GreetingSectionCollectionViewCell
            
            cell.configure(name: currentUserName())
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DailyTipCollectionViewCell.identifier,
                for: indexPath
            ) as! DailyTipCollectionViewCell
            
            cell.configure(
                title: currentDailyTipTitle(),
                tip: currentDailyTipText(),
                image: UIImage(systemName: "sparkles")
            )
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeRoutineSectionCollectionViewCell.identifier,
                for: indexPath
            ) as! HomeRoutineSectionCollectionViewCell
            
            cell.configure(
                steps: currentRoutineTitles(),
                completedCount: currentCompletedCount()
            )
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InsightSectionCollectionViewCell.identifier,
                for: indexPath
            ) as! InsightSectionCollectionViewCell
            
            cell.configure(
                headerTitle: "Track your skin progress",
                insightTitle: "Overall Skin Health",
                progress: 0.42,
                lowText: "Low",
                highText: "High",
                footerText: "Based on weekly inputs"
            )
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SkinMatrixSectionCollectionViewCell.identifier,
                for: indexPath
            ) as! SkinMatrixSectionCollectionViewCell
            
            let insight = skinInsights[indexPath.item]
            let subtitle = insightStatus(from: insight.percent)
            
            cell.configure(
                title: insight.title,
                subtitle: subtitle,
                progress: Float(insight.percent) / 100.0,
                image: UIImage(systemName: insight.icon),
                tintColor: .systemGreen
            )
            return cell
            
        case 5:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IngredientScannerCollectionViewCell.identifier,
                for: indexPath
            ) as! IngredientScannerCollectionViewCell
            
            cell.configure()
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeSectionHeader.identifier,
            for: indexPath
        ) as! HomeSectionHeader
        
        header.delegate = self
        
        switch indexPath.section {
        case 2:
            header.configure(title: "Routine", showSegment: true, selectedIndex: selectedSegment)
        case 3:
            header.configure(title: "Skin Insights", showSegment: false)
        case 5:
            header.configure(title: "Scan Analysis", showSegment: false)
        default:
            header.configure(title: "", showSegment: false)
        }
        
        return header
    }
}

extension HomeViewController: HomeSectionHeaderDelegate {
    func didChangeSegment(index: Int) {
        selectedSegment = index
        reloadRoutineData()
        HomeCollectionView.reloadSections(IndexSet(integer: 2))
    }
}

        // MARK: - Layout

extension HomeViewController {
    
    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            switch sectionIndex {
            case 0:
                return self.generateGreetingSection()
            case 1:
                return self.generateDailyTipSection()
            case 2:
                return self.generateRoutineSection()
            case 3:
                return self.generateInsightSection()
            case 4:
                return self.generateSkinInsightsSection()
            case 5:
                return self.generateIngredientScannerSection()
            default:
                return self.generateGreetingSection()
            }
        }
    }
    
    private func addHeader(to section: NSCollectionLayoutSection, height: CGFloat) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(height)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
    }
    
    func generateGreetingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func generateDailyTipSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(130)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 8,
            trailing: 0
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func generateRoutineSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(50)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func generateInsightSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(210)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(44)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func generateSkinInsightsSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(135)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )
        
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 10
        
        return section
    }
    
    func generateIngredientScannerSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(44)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
