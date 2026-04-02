//
//  ViewController.swift
//  homeScreenApp
//
//  Created by GEU on 06/02/26.
//

import UIKit

class HomeViewController: UIViewController, SkinMatrixToggleDelegate {
    
    var dataModel: DataModel!
    private var dailyTip: DailyTip?
    private var selectedRoutineTime: TimeOfDay = .morning
    private var showAllSkinMatrix = false
    private var allSkinInsights: [SkinInsight] {
        dataModel.skinMatrixInsights()
    }

    private var visibleSkinInsights: [SkinInsight] {
        showAllSkinMatrix ? allSkinInsights : Array(allSkinInsights.prefix(2))
    }

    private var currentUser: User? {
        dataModel.currentUser()
    }
    func chevronTapped() {
        performSegue(withIdentifier: "home_to_daily_routine_goals", sender: nil)
    }
    func didTapSkinMatrixToggle() {
        toggleSkinMatrix()
    }
    func routineChevronTapped() {
        performSegue(withIdentifier: "home_to_daily_routine_goals", sender: nil)
    }
    

    @IBOutlet weak var homeCollectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"

        guard dataModel != nil else {
                    fatalError(" dataModel is NOT set before HomeViewController loads")
                }

        view.backgroundColor = .systemGroupedBackground
        homeCollectionView.backgroundColor = .systemGroupedBackground

        dailyTip = dataModel.getDailyTip()

        registerCells()

        print(dataModel!)

        homeCollectionView.collectionViewLayout = generateLayout()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentWeeklyCheckIn()
    }

    private func presentWeeklyCheckIn() {
        UserDefaults.standard.removeObject(forKey: "lastWeeklyCheckInDate") // TODO: remove before release
        let routineStart = AppDataModel.shared.savedRoutines.first?.createdAt
            ?? Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())
            ?? Date()
        WeeklyCheckInViewController.presentIfDue(
            from: self,
            routineStartDate: routineStart,
            onSave: { data in print("Weekly check-in saved:", data) }
        )
    }

    func registerCells() {

        homeCollectionView.register(UINib(nibName: "headersReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headersReusableView.identifier)

        homeCollectionView.register(UINib(nibName: "SeeMoreForSkinMatrixCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: "toggle-kind", withReuseIdentifier: "skin_matrix_toggle_cell")

        homeCollectionView.register(UINib(nibName: "HelloHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "hello_cell")
        
        homeCollectionView.register(UINib(nibName: "DailyTipCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "daily_tip_cell")
        
        homeCollectionView.register(UINib(nibName: "RoutineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "routine_cell")
        
        homeCollectionView.register(UINib(nibName: "InsightsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "insight_cell")
        
        homeCollectionView.register(UINib(nibName: "BarcodeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "barcode_cell")

        
        homeCollectionView.register(UINib(nibName: "SkinMatrixCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "skin_matrix_cell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "home_to_daily_routine_goals" {

            guard let destination = segue.destination as? RoutineTimelineViewController else { return }

            destination.dataModel = dataModel

            if let user = currentUser {

                let steps = dataModel.routineStepsForHomeScreen(for: user.id)
                    .filter { $0.timeOfDay == selectedRoutineTime }

                destination.routineSteps = steps
                destination.title = selectedRoutineTime == .morning ? "Morning Routine" : "Evening Routine"
            }
        }
    }
    
    
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard currentUser != nil else { return 0 }

        switch section {
        case 0: return 1
        case 1: return dailyTip == nil ? 0 : 1
        case 2: return 1
        case 4: return visibleSkinInsights.count
        default: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hello_cell", for: indexPath) as! HelloHeaderCollectionViewCell
            cell.configure(name: currentUser?.username ?? "")
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "daily_tip_cell", for: indexPath) as! DailyTipCollectionViewCell
            if let tip = dailyTip { cell.configure(with: tip) }
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routine_cell", for: indexPath) as! RoutineCollectionViewCell
            
            guard let user = currentUser else { return cell }
            
            let steps = dataModel.routineStepsForHomeScreen(for: user.id)
                .filter { $0.timeOfDay == selectedRoutineTime }
            
            cell.configure(with: steps)
            
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insight_cell", for: indexPath) as! InsightsCollectionViewCell
            guard let user = currentUser else { return cell }
            let insight = dataModel.insightPoints(for: user.id)
            cell.configure(
                title: "Track your skin progress",
                progress: Float(insight.points) / 100,
                routinePercent: 78,
                description: "Based on weekly inputs"
            )
            return cell

        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skin_matrix_cell", for: indexPath) as! SkinMatrixCollectionViewCell
            let item = visibleSkinInsights[indexPath.item]
            cell.configure(icon: item.icon,
                           title: item.title,
                           subtitle: "Skin improvement",
                           percent: item.percent)
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barcode_cell", for: indexPath) as! BarcodeCollectionViewCell
            cell.configure(title: "Ingredient Scan",
                           description: "Scan product barcodes for instant ingredient analysis",
                           iconSystemName: "barcode.viewfinder",
                           showChevron: true)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == "toggle-kind" {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "skin_matrix_toggle_cell",
                for: indexPath
            ) as! SeeMoreForSkinMatrixCollectionViewCell

            view.configure(isExpanded: showAllSkinMatrix)
            view.delegate = self

            return view
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headersReusableView.identifier,
            for: indexPath
        ) as! headersReusableView

        switch indexPath.section {
        case 2:
            header.configure(title: "Routine",
                             showSegment: true,
                             selectedSegment: selectedRoutineTime == .morning ? 0 : 1)
            header.delegate = self
        case 3:
            header.configure(title: "Skin Insights")
        case 4:
            header.configure(title: "")
        case 5:
            header.configure(title: "Ingredient Scan")
        default:
            header.configure(title: "")
        }
        return header
    }
}

extension HomeViewController {

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section: NSCollectionLayoutSection
            
            switch sectionIndex {
            case 0:
                section = self.generateHelloSection()
                
            case 1:
                section = self.generateDailyTipSection()
                
            case 2:
                section = self.generateRoutineSection()
                section.boundarySupplementaryItems = [self.generateHeader()]
                
            case 3:
                section = self.generateInsightSection()
                section.boundarySupplementaryItems = [self.generateHeader()]
                
            case 4:
                section = self.generateSkinMatrixSection()
                
            case 5:
                section = self.simpleSection(180)
                section.boundarySupplementaryItems = [self.generateHeader()]
                
            default:
                section = self.simpleSection(180)
            }
            
            return section
        }
    }
    
    func generateHelloSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return section
    }
    
    func generateHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.pinToVisibleBounds = false
        header.zIndex = 2
        return header
    }

    
    func generateDailyTipSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.zero
        return section
    }
    
    func generateRoutineSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.zero
        return section
    }

    
    func generateInsightSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(230))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.zero
        return section
    }
    
    
    func generateSkinMatrixSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize( widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(210) )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets( top: 0, leading: 0, bottom: 0,  trailing: 0 )
        let groupSize = NSCollectionLayoutSize( widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(210) )
        let group = NSCollectionLayoutGroup.horizontal( layoutSize: groupSize, subitems: [item, item] )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets( top: 0, leading: 0, bottom: 0, trailing: 0 )
        let toggle = NSCollectionLayoutBoundarySupplementaryItem( layoutSize: NSCollectionLayoutSize( widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44) ), elementKind: "toggle-kind", alignment: .bottom )

        section.boundarySupplementaryItems = [toggle]

        return section
    }
    
    func simpleSection(_ height: CGFloat) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize:
            .init(widthDimension: .fractionalWidth(1),
                  heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize:
            .init(widthDimension: .fractionalWidth(1),
                  heightDimension: .absolute(height)),
            subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    func routineSegmentChanged(index: Int) {
        selectedRoutineTime = index == 0 ? .morning : .evening
        homeCollectionView.reloadSections(IndexSet(integer: 2))
    }

    func toggleSkinMatrix() {
        showAllSkinMatrix.toggle()
        homeCollectionView.performBatchUpdates {
            homeCollectionView.reloadSections(IndexSet(integer: 4))
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 2 {
            performSegue(withIdentifier: "home_to_daily_routine_goals", sender: indexPath)
        }
    }
}
