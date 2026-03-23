//
//  RoutineTimelineViewController.swift
//  homeScreenApp
//
//  Created by GEU on 13/02/26.
//

import UIKit

class RoutineTimelineViewController: UIViewController {
    var dataModel: DataModel!
    var routineSteps: [RoutineStep] = []

    @IBOutlet weak var collectionView: UICollectionView!
    

        private let calendar = Calendar.current
        private var dates: [Date] = []
        private var selectedIndex: Int = 0

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Routine Timeline"
            navigationItem.largeTitleDisplayMode = .never

            setupCollectionView()
            registerCellNib()
            setupLayout()

            generateTimelineDates()
            loadRoutine()

            collectionView.reloadData()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            scrollTimelineToSelected(animated: false)
        }
    }

    // MARK: - Data

    extension RoutineTimelineViewController {

        private func generateTimelineDates() {

            dates.removeAll()

            let range = -30...30

            for offset in range {
                if let date = calendar.date(byAdding: .day, value: offset, to: Date()) {
                    dates.append(date)
                }
            }

            selectedIndex = range.count / 2
        }

        private func loadRoutine() {

            let user = dataModel.currentUser()

            routineSteps = dataModel
                .routineStepsForHomeScreen(for: user.id)
        }

        private func dateForIndex(_ index: Int) -> Date {

            let offset = index - (dates.count / 2)

            return calendar.date(byAdding: .day, value: offset, to: Date())!
        }

        private func scrollTimelineToSelected(animated: Bool) {

            let idx = IndexPath(item: selectedIndex, section: 0)

            guard selectedIndex < dates.count else { return }

            collectionView.scrollToItem(
                at: idx,
                at: .centeredHorizontally,
                animated: animated
            )
        }
    }

    // MARK: - CollectionView Setup

    extension RoutineTimelineViewController {

        private func setupCollectionView() {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.alwaysBounceVertical = true
        }

        private func registerCellNib() {

            collectionView.register(
                UINib(nibName: "TimelineCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: TimelineCollectionViewCell.reuseIdentifier
            )

            collectionView.register(
                UINib(nibName: "ProgressCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "progressCell"
            )

            collectionView.register(
                UINib(nibName: "InsideRoutineCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "routineCell"
            )
            
            collectionView.register(
                UINib(nibName: "headersReusableView", bundle: nil),
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: headersReusableView.identifier
            )
        }

        private func setupLayout() {

            let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in

                switch sectionIndex {

                case 0:
                    return self.generateDateSection()

                case 1:
                    return self.generateProgressSection()

                default:
                    return self.generateRoutineSection()
                }
            }

            collectionView.collectionViewLayout = layout
        }
    }

    // MARK: - DataSource

    extension RoutineTimelineViewController: UICollectionViewDataSource {

        func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {

            switch section {

            case 0:
                return dates.count

            case 1:
                return 1

            default:
                return routineSteps.count
            }
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            switch indexPath.section {

            case 0:

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TimelineCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! TimelineCollectionViewCell

                let date = dates[indexPath.item]

                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "E"

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd"

                let day = String(dayFormatter.string(from: date).prefix(1))
                let dateString = dateFormatter.string(from: date)

                let isToday = calendar.isDateInToday(date)

                cell.configure(
                    day: day,
                    date: dateString,
                    isToday: isToday,
                    isSelected: indexPath.item == selectedIndex
                )

                return cell

            case 1:

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "progressCell",
                    for: indexPath
                ) as! ProgressCollectionViewCell

                let selectedDate = dateForIndex(selectedIndex)

                let completed = routineSteps.filter {
                    dataModel.isStepDone(stepID: $0.id, date: selectedDate)
                }.count

                cell.configure(
                    total: routineSteps.count,
                    completed: completed
                )

                return cell

            default:

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "routineCell",
                    for: indexPath
                ) as! InsideRoutineCollectionViewCell

                let step = routineSteps[indexPath.item]

                let selectedDate = dateForIndex(selectedIndex)

                let done = dataModel.isStepDone(
                    stepID: step.id,
                    date: selectedDate
                )

                cell.configure(
                    title: step.stepTitle,
                    detail: step.instructionText,
                    done: done
                )

                cell.toggleHandler = { [weak self] in

                    guard let self else { return }

                    self.dataModel.toggleStep(
                        stepID: step.id,
                        date: selectedDate
                    )

                    self.collectionView.reloadSections(IndexSet(integer: 1))
                    self.collectionView.reloadItems(at: [indexPath])
                }

                return cell
            }
        }
    }

    // MARK: - Delegate

    extension RoutineTimelineViewController: UICollectionViewDelegate {

        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            if indexPath.section == 0 {

                selectedIndex = indexPath.item

                collectionView.reloadSections(IndexSet(integer: 0))
                collectionView.reloadSections(IndexSet(integer: 1))
                collectionView.reloadSections(IndexSet(integer: 2))

                scrollTimelineToSelected(animated: true)
            }
        }
    }

    // MARK: - Layout

extension RoutineTimelineViewController {
    
    func generateDateSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(60),
            heightDimension: .absolute(80)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(60),
            heightDimension: .absolute(80)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 16,
            bottom: 10,
            trailing: 16
        )

        return section
    }
    
    func generateProgressSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(120)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 10,
            trailing: 16
        )
        
        return NSCollectionLayoutSection(group: group)
    }
    
    func generateRoutineSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(90)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(90)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 16,
            bottom: 30,
            trailing: 16
        )
        
        return section
    }
    
    func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: headersReusableView.identifier,
            for: indexPath
        ) as! headersReusableView
        
        switch indexPath.section {
            
        case 1:
            header.configure(
                title: "Step Breakdown",
                showChevron: false,
                showSegment: true
            )
            
        default:
            header.configure(title: "")
        }
        
        return header
    }
}
