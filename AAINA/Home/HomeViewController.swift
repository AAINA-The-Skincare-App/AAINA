//
//  HomeViewController.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    var dataModel: AppDataModel!
    
    private let defaultDataModel = DataModel()
    
    private var selectedSegment: Int = 0
    private var steps: [RoutineStep] = []
    private var aiSteps: [AIRoutineStep] = []
    private var aiOutput: AIRoutineOutput?
    private let skincareArticles: [(title: String, meta: String)] = [
        ("Understanding Retinol", "4 min"),
        ("Layering Ingredients", "5 min"),
        ("Skin Hydration", "3 min"),
        ("SPF Myths Debunked", "4 min")
    ]
    private let nutritionArticles: [(title: String, meta: String)] = [
        ("Collagen Boost", "8 min"),
        ("Vitamins your skin love", "3 min"),
        ("Nutrition Myths", "5 min"),
        ("What to Avoid?", "4 min")
    ]
    
    private var currentUserID: String {
        defaultDataModel.currentUser().id
    }
    
    private var skinInsights: [SkinInsight] {
        dataModel.skinInsights
    }
    
    func insightStatus(from percent: Int) -> String {
        switch percent {
        case 75...100: return "Improving"
        case 50..<75:  return "Consistent"
        default:       return "Declined"
        }
    }
    
    @IBOutlet weak var HomeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dataModel == nil {
            dataModel = AppDataModel.shared
        }
        
        title = ""
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.applyAINABackground()
        
        aiOutput = dataModel.aiRoutine
        
        setupCollectionView()
        registerCells()
        reloadRoutineData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        aiOutput = dataModel.aiRoutine
        reloadRoutineData()
        HomeCollectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentWeeklyCheckInIfNeeded()
    }

    private func presentWeeklyCheckInIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self, self.presentedViewController == nil else { return }
            let vc = WeeklyCheckInViewController()
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 28
            }
            self.present(vc, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true

        switch segue.identifier {
        case "home_to_ingredient_scan":
            guard let scanner = segue.destination as? ScannerViewController else { return }
            scanner.title = "Ingredient scanner"
            scanner.step = "Ingredient scanner"
        case "home_to_profile_placeholder":
            segue.destination.title = ""
            segue.destination.view.applyAINABackground()
        case "home_to_face_scan", "home_to_skin_insights":
            segue.destination.title = ""
        default:
            break
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            openHomeDestination(withIdentifier: "home_to_face_scan")
        case 2:
            openHomeDestination(withIdentifier: "home_to_ingredient_scan")
        case 4:
            openHomeDestination(withIdentifier: "home_to_skin_insights")
        default:
            break
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension HomeViewController {
    
    private func setupCollectionView() {
        HomeCollectionView.delegate   = self
        HomeCollectionView.dataSource = self
        HomeCollectionView.backgroundColor = .clear
        HomeCollectionView.showsVerticalScrollIndicator = false
        HomeCollectionView.alwaysBounceVertical = true
        HomeCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    private func registerCells() {
        HomeCollectionView.register(UINib(nibName: "GreetingSectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: GreetingSectionCollectionViewCell.identifier)
        
        HomeCollectionView.register(UINib(nibName: "HomeRoutineSectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: HomeRoutineSectionCollectionViewCell.identifier)
        
        HomeCollectionView.register(UINib(nibName: "InsightSectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: InsightSectionCollectionViewCell.identifier)
        
        HomeCollectionView.register(UINib(nibName: IngredientScannerCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: IngredientScannerCollectionViewCell.identifier)
        
        HomeCollectionView.register(UINib(nibName: ArticlesCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ArticlesCollectionViewCell.identifier)
        
        HomeCollectionView.register(UINib(nibName: "HomeSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeader.identifier)
    }
}

extension HomeViewController {
    
    private func reloadRoutineData() {
        if let ai = aiOutput {
            aiSteps = selectedSegment == 0 ? ai.morning : ai.evening
            steps = []
        }
        else {
            aiSteps = []
            steps = selectedSegment == 0
                ? defaultDataModel.morningSteps(for: currentUserID)
                : defaultDataModel.eveningSteps(for: currentUserID)
        }
    }
    
    private func currentUserName() -> String {
        dataModel.userProfile?.name ?? ""
    }
    
    private func currentRoutineTitles() -> [String] {
        let titles = aiOutput != nil ? aiSteps.map { $0.productType.rawValue } : steps.map { $0.type.rawValue }
        return titles.map { formattedRoutineTitle($0) }
    }

    private func formattedRoutineTitle(_ title: String) -> String {
        title
            .split(separator: " ")
            .map { word in
                guard let first = word.first else { return "" }
                return first.uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }
    
    private func currentCompletedCount() -> Int { 0 }

    private func currentRoutineCardHeight() -> CGFloat {
        let stepCount = max(currentRoutineTitles().count, 1)
        let rowHeight: CGFloat = 42
        let rowSpacing: CGFloat = 18
        let cellVerticalPadding: CGFloat = 32
        let containerChromeHeight: CGFloat = 83
        let rowsHeight = CGFloat(stepCount) * rowHeight
        let spacingHeight = CGFloat(max(stepCount - 1, 0)) * rowSpacing
        return max(280, cellVerticalPadding + containerChromeHeight + rowsHeight + spacingHeight)
    }

    private func openHomeDestination(withIdentifier identifier: String) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        performSegue(withIdentifier: identifier, sender: self)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    // Sections:
    // 0 — Greeting
    // 1 — Face Scan
    // 2 — Ingredient Scanner
    // 3 — Routine
    // 4 — Skin Insights
    // 5 — Get smart about skincare
    // 6 — Nutritional fuel
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 5: return skincareArticles.count
        case 6: return nutritionArticles.count
        default: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GreetingSectionCollectionViewCell.identifier, for: indexPath) as! GreetingSectionCollectionViewCell
            cell.configure(name: currentUserName())
            cell.onProfileTapped = { [weak self] in
                self?.openHomeDestination(withIdentifier: "home_to_profile_placeholder")
            }
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientScannerCollectionViewCell.identifier, for: indexPath) as! IngredientScannerCollectionViewCell
            cell.configure(
                title: "Face Scan",
                description: "Scan your face for instant analysis.",
                imageName: "FemaleFace"
            )
            cell.onInfoTapped = { [weak self] in
                self?.presentScannerInfo(
                    title: "Face Scanner",
                    message: """
                    The Face Scanner uses your camera image to study visible skin signals such as texture, redness, dryness, oiliness, pigmentation, and acne-prone areas.

                    It helps AAINA understand your current skin condition, surface-level concerns, and routine needs so your insights and recommendations can feel more personal.

                    Use it in good lighting with your face centered and makeup-free where possible. It is a skincare guidance tool, not a medical diagnosis.
                    """
                )
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientScannerCollectionViewCell.identifier, for: indexPath) as! IngredientScannerCollectionViewCell
            cell.configure(
                title: "Ingredient Scan",
                description: "Scan your product labels.",
                imageName: "Products"
            )
            cell.onInfoTapped = { [weak self] in
                self?.presentScannerInfo(
                    title: "Ingredient Scanner",
                    message: """
                    The Ingredient Scanner reads a product label and looks for ingredients that matter to your routine, including actives, possible irritants, allergy triggers, and combinations that may not suit your skin goals.

                    It can help compare a product against your saved routine, highlight useful ingredients, and flag conflicts before you add something new.

                    Scan a clear label with the full ingredient list visible for the best result.
                    """
                )
            }
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRoutineSectionCollectionViewCell.identifier, for: indexPath) as! HomeRoutineSectionCollectionViewCell
            cell.delegate = self
            cell.configure(
                steps: currentRoutineTitles(),
                completedCount: currentCompletedCount(),
                selectedSegment: selectedSegment
            )
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsightSectionCollectionViewCell.identifier, for: indexPath) as! InsightSectionCollectionViewCell
            cell.configure(
                description: "From your last scan, your skin shows signs of improved hydration and reduced redness."
            )
            cell.onActionTapped = { [weak self] in
                self?.openHomeDestination(withIdentifier: "home_to_skin_insights")
            }
            
            return cell

        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticlesCollectionViewCell.identifier, for: indexPath) as! ArticlesCollectionViewCell
            let article = skincareArticles[indexPath.item]
            cell.configure(title: article.title, meta: article.meta)
            return cell

        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticlesCollectionViewCell.identifier, for: indexPath) as! ArticlesCollectionViewCell
            let article = nutritionArticles[indexPath.item]
            cell.configure(title: article.title, meta: article.meta)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeSectionHeader.identifier,
            for: indexPath
        ) as! HomeSectionHeader
        
        switch indexPath.section {
        case 3: header.configure(title: "Routine",          showSegment: false)
        case 4: header.configure(title: "Skin Insights",    showSegment: false)
        case 5: header.configure(title: "Get smart about skincare", showSegment: false)
        case 6: header.configure(title: "Nutritional fuel", showSegment: false)
        default: header.configure(title: "",                showSegment: false)
        }
        
        return header
    }
}

extension HomeViewController: HomeRoutineSectionCollectionViewCellDelegate {
    func homeRoutineCell(_ cell: HomeRoutineSectionCollectionViewCell, didChangeSegment index: Int) {
        selectedSegment = index
        reloadRoutineData()
        HomeCollectionView.collectionViewLayout.invalidateLayout()
        HomeCollectionView.reloadSections(IndexSet(integer: 3))
    }
}


extension HomeViewController {
    
    func generateLayout() -> UICollectionViewLayout {
            UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
                guard let self else { return nil }
                switch sectionIndex {
                case 0: return self.generateGreetingSection()
                case 1: return self.generateIngredientScannerSection()
                case 2: return self.generateIngredientScannerSection()
                case 3: return self.generateRoutineSection()
                case 4: return self.generateInsightSection()
                case 5: return self.generateArticlesSection()
                case 6: return self.generateArticlesSection()
                default: return self.generateGreetingSection()
                }
            }
        }
    
    func generateGreetingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(116)), subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        return NSCollectionLayoutSection(group: group)
    }
    
    func generateRoutineSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(currentRoutineCardHeight())), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [makeHeader(height: 50)]
        return section
    }
    
    func generateInsightSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [makeHeader(height:50)]
        return section
    }
    
    func generateIngredientScannerSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(176)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [makeHeader(height: 0)]
        return section
    }

    func generateArticlesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .absolute(200)), subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16)
        section.boundarySupplementaryItems = [makeHeader(height: 50)]
        return section
    }
    
    private func makeHeader(height: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
}

private extension HomeViewController {
    func presentScannerInfo(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
}
