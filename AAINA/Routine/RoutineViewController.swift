import UIKit

final class RoutineViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedDate: Date = Date()
    private let dataModel = DataModel()
    private var selectedSegment: Int = 0
    private var steps: [RoutineStep] = []
    private var aiSteps: [AIRoutineStep] = []
    private var aiOutput: AIRoutineOutput?
    private var morningCheckedSteps: Set<String> = []
    private var eveningCheckedSteps: Set<String> = []
    private let headerDivider = UIView()
    private let peachOverlay = UIView()
    
    private var currentUserID: String {
        dataModel.currentUser().id
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
       view.applyAINABackground()
        title = "Routine"
     
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setupCalendarButton()   // 🔥 ADDED
        setupCollectionView()
       //setupHeaderDivider()
        loadData()
        setupPeachOverlay()
        
        let appearance = UINavigationBarAppearance()
       
        

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.ainaTextPrimary
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ainaTextPrimary
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAINABackground()
        
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let width = collectionView.bounds.width - 32
        
        if flow.estimatedItemSize.width != width {
            flow.estimatedItemSize = CGSize(width: width, height: 200)
            collectionView.collectionViewLayout.invalidateLayout()
            
        }
        
    }
    
    // MARK: - Calendar Button
    
    private func setupCalendarButton() {
        
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "calendar", withConfiguration: config)
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.ainaTextPrimary
        button.backgroundColor = UIColor.ainaGlassSurface
        
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.ainaCardShadowColor.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        button.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    @objc private func calendarTapped() {

        let vc = CalendarPopupViewController()
        vc.modalPresentationStyle = .overFullScreen

        // 🔥 Pass selected date TO calendar
        vc.selectedDate = selectedDate

        // 🔥 Calendar → VC
        vc.onDateSelected = { [weak self] date in
            guard let self = self else { return }

            self.selectedDate = date

            // 🔥 Update timeline cell
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TimelineContainerCollectionViewCell {
                cell.updateSelectedDate(date)
            }
        }

        present(vc, animated: false)
    }
}
    // MARK: - Setup

    extension RoutineViewController {

   
    private func setupCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .automatic

        // Timeline
        collectionView.register(
            UINib(nibName: "TimelineContainerCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TimelineContainerCollectionViewCell"
        )

        // Steps
        collectionView.register(
            UINib(nibName: "StepCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: StepCollectionViewCell.identifier
        )

        // Segmented Header
        collectionView.register(
            UINib(nibName: "Segmented_CollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Segmented_CollectionReusableView.identifier
        )
        collectionView.register(
            ProgressCardCollectionViewCell.self,
            forCellWithReuseIdentifier: ProgressCardCollectionViewCell.identifier
        )
     
        

        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flow.scrollDirection = .vertical
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flow.minimumLineSpacing = 20
        flow.minimumInteritemSpacing = 0
       
        flow.sectionHeadersPinToVisibleBounds = false
        flow.estimatedItemSize = CGSize(width: collectionView.bounds.width - 32, height: 200)
    }

    private func loadData() {
        aiOutput = dataModel.loadAIRoutine()
        reloadSteps()
    }

    private func reloadSteps() {

        if let ai = aiOutput {
            aiSteps = selectedSegment == 0 ? ai.morning : ai.evening
            steps = []
        } else {
            aiSteps = []
            steps = selectedSegment == 0
                ? dataModel.morningSteps(for: currentUserID)
                : dataModel.eveningSteps(for: currentUserID)
        }

        collectionView.reloadSections(IndexSet(integer: 2))
    }
 

    }

    // MARK: - DataSource

    extension RoutineViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {

            switch section {
            
            case 0:
                return UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)// timeline
            case 1:
            
                return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)// segmented
            case 2:
          
                return UIEdgeInsets(top: 2, left: 16, bottom: 20, right: 16) // cards
            default:
                return .zero
            }
        }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0: return 1
        case 1: return 0
        case 2:
            let count = aiOutput != nil ? aiSteps.count : steps.count
            return count + 1   // 🔥 progress card
        default: return 0
        }
    }
        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            switch indexPath.section {

            case 0:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "TimelineContainerCollectionViewCell",
                    for: indexPath
                ) as! TimelineContainerCollectionViewCell

                cell.onDateSelected = { [weak self] date in
                    self?.selectedDate = date
                }

                return cell

            case 1:
                return UICollectionViewCell()

            case 2:

                // 🔥 PROGRESS CARD
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ProgressCardCollectionViewCell.identifier,
                        for: indexPath
                    ) as! ProgressCardCollectionViewCell

                    let total = aiOutput != nil ? aiSteps.count : steps.count
                    let currentCheckedSteps = selectedSegment == 0 ? morningCheckedSteps : eveningCheckedSteps
                    let completed = currentCheckedSteps.count

                    cell.configure(completed: completed, total: total)
                    return cell
                }

                // 🔥 STEP CELLS
                let index = indexPath.item - 1

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: StepCollectionViewCell.identifier,
                    for: indexPath
                ) as! StepCollectionViewCell

                let currentCheckedSteps = selectedSegment == 0 ? morningCheckedSteps : eveningCheckedSteps

                if aiOutput != nil {
                    let aiStep = aiSteps[index]
                    let isChecked = currentCheckedSteps.contains(aiStep.id) // ✅ FIXED

                    cell.configure(aiStep: aiStep, isChecked: isChecked)

                    cell.checkChanged = { [weak self] checked in
                        guard let self = self else { return }

                        if self.selectedSegment == 0 {
                            if checked {
                                self.morningCheckedSteps.insert(aiStep.id)
                            } else {
                                self.morningCheckedSteps.remove(aiStep.id)
                            }
                        } else {
                            if checked {
                                self.eveningCheckedSteps.insert(aiStep.id)
                            } else {
                                self.eveningCheckedSteps.remove(aiStep.id)
                            }
                        }

                        self.collectionView.reloadItems(at: [
                            IndexPath(item: 0, section: 2),
                            indexPath
                        ])
                    }

                } else {
                    let step = steps[index]
                    let ingredients = dataModel.ingredientNames(for: step)
                    let isChecked = currentCheckedSteps.contains(step.id) 

                    cell.configure(step: step,
                                   ingredients: ingredients,
                                   isChecked: isChecked)

                    cell.checkChanged = { [weak self] checked in
                        guard let self = self else { return }

                        if self.selectedSegment == 0 {
                            if checked {
                                self.morningCheckedSteps.insert(step.id)
                            } else {
                                self.morningCheckedSteps.remove(step.id)
                            }
                        } else {
                            if checked {
                                self.eveningCheckedSteps.insert(step.id)
                            } else {
                                self.eveningCheckedSteps.remove(step.id)
                            }
                        }

                        self.collectionView.reloadItems(at: [
                            IndexPath(item: 0, section: 2),
                            indexPath
                        ])
                    }
                }

                return cell

            default:
                return UICollectionViewCell()
            }
        
        }
    }

    

    // MARK: - Header

    extension RoutineViewController {

   
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard indexPath.section == 1 else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Segmented_CollectionReusableView.identifier,
            for: indexPath
        ) as! Segmented_CollectionReusableView

        header.segmentChanged = { [weak self] index in
            self?.selectedSegment = index
            self?.reloadSteps()
        }

        return header
    }
   

    }

    // MARK: - Layout

    extension RoutineViewController: UICollectionViewDelegateFlowLayout {

 
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        return section == 1
        ? CGSize(width: collectionView.frame.width, height: 40)
        : .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32

        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 80)
        case 2:
            if indexPath.item == 0 {
                return CGSize(width: width, height: 80) // 🔥 progress card smaller
            }
            return CGSize(width: width, height: 170) // 🔥 step cards tighter
        default:
            return .zero
        }
    }


    }

    // MARK: - Navigation

    extension RoutineViewController: UICollectionViewDelegate {

   
        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            // ❌ Ignore progress card
            guard indexPath.section == 2, indexPath.item != 0 else { return }

            let vc = RoutineDetailViewController()
            vc.dataModel = dataModel

            let index = indexPath.item - 1

            if aiOutput != nil {
                vc.aiStep = aiSteps[index]
            } else {
                vc.step = steps[index]
            }

            navigationController?.pushViewController(vc, animated: true)
        }
        private func setupHeaderDivider() {

            headerDivider.backgroundColor = UIColor.white.withAlphaComponent(1)
            headerDivider.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(headerDivider)

            NSLayoutConstraint.activate([
                headerDivider.topAnchor.constraint(equalTo: collectionView.topAnchor),
                headerDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerDivider.heightAnchor.constraint(equalToConstant: 1)
            ])
            
        }
        private func setupPeachOverlay() {

            
            peachOverlay.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(peachOverlay, at: 1) // above gradient, below content

            NSLayoutConstraint.activate([
                peachOverlay.topAnchor.constraint(equalTo: view.topAnchor),
                peachOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                peachOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                peachOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        }


    
