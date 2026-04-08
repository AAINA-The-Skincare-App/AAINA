//
//  TimelineContainerCollectionViewCell.swift
//  AAINA
//
//  Created by GEU on 27/03/26.
//

import UIKit

class TimelineContainerCollectionViewCell: UICollectionViewCell {

 
    @IBOutlet weak var collectionView: UICollectionView!
   
   
        var onDateSelected: ((Date) -> Void)?

        private let calendar = Calendar.current
        private var dates: [Date] = []
        private var selectedDate: Date = Date()
        private let backgroundStrip = UIView()
        // MARK: - Lifecycle

        override func layoutSubviews() {
            super.layoutSubviews()

            if collectionView.delegate == nil {
                setupDates(for: selectedDate)
                setupCollectionView()
                scrollToSelectedDate()
            }
        }

        // MARK: - Setup Dates (FULL MONTH)

        private func setupDates(for date: Date) {
            dates.removeAll()

            let range = calendar.range(of: .day, in: .month, for: date)!
            let components = calendar.dateComponents([.year, .month], from: date)

            for day in range {
                var comp = components
                comp.day = day
                if let d = calendar.date(from: comp) {
                    dates.append(d)
                }
            }

            selectedDate = date
        }

        // MARK: - Setup CollectionView

        private func setupCollectionView() {

            backgroundColor = .clear
            contentView.backgroundColor = .clear
            collectionView.backgroundColor = .clear

            collectionView.delegate = self
            collectionView.dataSource = self

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

            collectionView.collectionViewLayout = layout
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.decelerationRate = .fast

            collectionView.register(
                UINib(nibName: "TimelineCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: TimelineCollectionViewCell.reuseIdentifier
            )
        }

        // MARK: - Scroll to Selected Date

        private func scrollToSelectedDate() {
            DispatchQueue.main.async {
                if let index = self.dates.firstIndex(where: {
                    self.calendar.isDate($0, inSameDayAs: self.selectedDate)
                }) {
                    self.collectionView.scrollToItem(
                        at: IndexPath(item: index, section: 0),
                        at: .centeredHorizontally,
                        animated: false
                    )
                }
            }
        }

        // MARK: - External Update (Calendar → Timeline)

        func updateSelectedDate(_ date: Date) {
            setupDates(for: date)

            if let index = dates.firstIndex(where: {
                calendar.isDate($0, inSameDayAs: date)
            }) {
                collectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }

            collectionView.reloadData()
        }
    }

    // MARK: - CollectionView

    extension TimelineContainerCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            return dates.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TimelineCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! TimelineCollectionViewCell

            let date = dates[indexPath.item]

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"

            let isToday = calendar.isDateInToday(date)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

            cell.configure(
                day: String(dayFormatter.string(from: date).prefix(1)),
                date: dateFormatter.string(from: date),
                isToday: isToday,
                isSelected: isSelected
            )

            return cell
        }

        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            let selected = dates[indexPath.item]
            selectedDate = selected

            // 🔥 Notify parent
            onDateSelected?(selected)

            UIView.animate(withDuration: 0.2) {
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            }
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: 50, height: 90)
        }
    }
