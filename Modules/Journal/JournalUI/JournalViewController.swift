//
//  JournalViewController.swift
//  JournalUI
//

import UIKit
import EventKit
import EventKitUI

class JournalViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
        
        // MARK: - Reminder store
        let eventStore = EKEventStore()
        
        // Stored only inside app
        var reminders: [EKEvent] = []
        
        // MARK: - Timeline data
        private(set) var dates: [String] = []
        private(set) var days: [String] = []
        var selectedIndex: Int = 0
        var todayIndex: Int = 0

        
        // MARK: - Journal entries
        var journalEntries: [String] = []
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Journal"
            
            journalEntries = [
                "Skin felt oily today...",
                "Redness reduced slightly.",
                "Tried new moisturizer."
            ]
            
            setupCollectionView()
            registerCellNib()
            setupLayout()
            
            generateTimelineDates()
            collectionView.reloadData()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            scrollTimelineToSelected(animated: false)
        }
        
        // MARK: - Actions
        @IBAction func addJournalEntryTapped(_ sender: Any) {
            print("Add entry tapped")
        }
        
        @IBAction func addReminderTapped(_ sender: UIButton) {
            
            print("Add Reminder Button Tapped")
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {

                        if granted {

                            let editVC = EKEventEditViewController()
                            editVC.eventStore = self.eventStore

                            let event = EKEvent(eventStore: self.eventStore)
                            event.calendar = self.eventStore.defaultCalendarForNewEvents

                            editVC.event = event
                            editVC.editViewDelegate = self

                            self.present(editVC, animated: true)

                        } else {
                            print("Calendar permission denied")
                        }
                    }
                }
            }
        
        // MARK: - Timeline generation
    private func generateTimelineDates() {
        dates.removeAll()
        days.removeAll()

        let calendar = Calendar.current
        let today = Date()

        // find nearest previous Sunday
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = weekday - 1

        guard let startSunday = calendar.date(
            byAdding: .day,
            value: -daysFromSunday,
            to: today
        ) else { return }

        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "dd"

        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "EEE"

        // generate multiple weeks
        let totalDays = 7 * 12 // 12 weeks buffer

        for offset in 0..<totalDays {
            if let d = calendar.date(byAdding: .day,
                                      value: offset,
                                      to: startSunday) {

                dates.append(formatterDate.string(from: d))
                days.append(formatterDay.string(from: d))
            }
        }

        // today index
        selectedIndex = daysFromSunday
        todayIndex = selectedIndex
    }

        
        private func dateForIndex(_ index: Int) -> Date {
            let offset = index - (dates.count / 2)
            return Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        }
        
        // MARK: - Scroll helper
        private func scrollTimelineToSelected(animated: Bool) {
            let idx = IndexPath(item: selectedIndex, section: 0)
            guard selectedIndex < dates.count else { return }
            collectionView.scrollToItem(at: idx, at: .centeredHorizontally, animated: animated)
        }
        
        // MARK: - Collection setup
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
                UINib(nibName: "ReminderCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "reminder_cell"
            )
            
            collectionView.register(
                UINib(nibName: "EntryCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "entry_cell"
            )
            
            collectionView.register(
                UINib(nibName: "SectionHeaderView", bundle: nil),
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "SectionHeaderView"
            )
        }
        
        // MARK: - Layout
        private func setupLayout() {
            let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
                switch sectionIndex {
                case 0: return self.generateTimelineSection()
                case 1: return self.generateReminderSection()
                default: return self.generateEntriesSection()
                }
            }
            collectionView.collectionViewLayout = layout
        }
    }
    
    // MARK: - Collection View
    extension JournalViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }
        
        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            switch section {
            case 0: return dates.count
            case 1:
                print("Cells in reminder section:", reminders.count)
return reminders.count
            default: return journalEntries.count
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
                
                cell.configure(
                    day: days[indexPath.item],
                    date: dates[indexPath.item],
                    isToday: indexPath.item == todayIndex,
                    isSelected: indexPath.item == selectedIndex
                )
                return cell
                
            case 1:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "reminder_cell",
                    for: indexPath
                ) as! ReminderCollectionViewCell
                
                cell.configure(with: reminders[indexPath.item])
                return cell
                
            default:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "entry_cell",
                    for: indexPath
                ) as! EntryCollectionViewCell
                
                cell.configure(text: journalEntries[indexPath.item])
                return cell
            }
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath
            ) as! SectionHeaderView
            
            header.titleLabel.text =
            indexPath.section == 1 ? "Reminders" : "My Entries"
            
            return header
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {
            if indexPath.section == 0 {
                selectedIndex = indexPath.item
                collectionView.reloadSections(IndexSet(integer: 0))
                scrollTimelineToSelected(animated: true)
            }
        }
    }
    
    // MARK: - Layout sections
    extension JournalViewController {
        
        func generateTimelineSection() -> NSCollectionLayoutSection {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // small spacing between cells
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 4,
                bottom: 0,
                trailing: 4
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)

            section.orthogonalScrollingBehavior = .groupPaging

            // IMPORTANT: no side padding
            section.contentInsets = .zero

            return section
        }


        
        func generateReminderSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            return section
        }
        
        func generateEntriesSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
    
    // MARK: - Event Delegate
    extension JournalViewController: EKEventEditViewDelegate {
        
        func eventEditViewController(_ controller: EKEventEditViewController,
                                     didCompleteWith action: EKEventEditViewAction) {
            
            if action == .saved, let event = controller.event {
                
                print("Event title:", event.title ?? "nil")
                
                reminders.append(event)
                print("Total reminders:", reminders.count)
                
                // remove from calendar so it stays app-only
                try? eventStore.remove(event, span: .thisEvent)
                
                collectionView.reloadSections(IndexSet(integer: 1))
            }
            
            controller.dismiss(animated: true)
            print("Editor closed with action:", action.rawValue)
        }
    }

