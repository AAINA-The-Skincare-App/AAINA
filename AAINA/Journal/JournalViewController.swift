//
//  JournalViewController.swift
//  JournalUI
//

import UIKit
import EventKit
import EventKitUI
import UserNotifications

class JournalViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var journalEntryButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!

    // MARK: - Reminder store
    let eventStore = EKEventStore()
    private var allReminders: [EKEvent] = []
    var reminders: [EKEvent] = []

    // MARK: - Timeline data
    private var timelineStartDate: Date = Date()
    private var dates: [String] = []
    private var days: [String] = []
    var selectedIndex: Int = 0
    var todayIndex: Int = 0

    // MARK: - Journal entries
    private var allJournalEntries: [JournalEntry] = []
    var journalEntries: [JournalEntry] = []

    // MARK: - See More / See Less state
    private let maxVisibleRows = 2
    private var remindersExpanded = false
    private var entriesExpanded = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersistedData()

        view.backgroundColor = .white
        setupNavigationBar()
        setupButtons()
        setupCollectionView()
        setupLayout()
        generateTimelineDates()
        collectionView.reloadData()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterRemindersForSelectedDate()
        filterEntriesForSelectedDate()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollTimelineToSelected(animated: false)
    }

    // MARK: - Buttons
    private func setupButtons() {
        applyGlassConfig(to: journalEntryButton, title: " Journal Entry", icon: "plus")
        applyGlassConfig(to: reminderButton, title: " Reminder", icon: "plus")
    }

    private func applyGlassConfig(to button: UIButton, title: String, icon: String) {
        var config = UIButton.Configuration.glass()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.cornerStyle = .capsule
        button.configuration = config
    }

    // MARK: - Navigation bar
    private func setupNavigationBar() {
        title = "Journal"

        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(calendarTapped)
        )
        calendarButton.tintColor = .label
        navigationItem.rightBarButtonItem = calendarButton
    }

    @objc private func calendarTapped() {
        // Guard: only present if this VC is currently visible
        guard viewIfLoaded?.window != nil else { return }
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = .systemRed

        guard let selectedDate = Calendar.current.date(byAdding: .day, value: selectedIndex, to: timelineStartDate)
        else { return }
        picker.date = selectedDate

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: sheet.view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: sheet.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: sheet.view.trailingAnchor),
        ])
        let height: CGFloat = 360
        sheet.view.heightAnchor.constraint(equalToConstant: height + 80).isActive = true

        sheet.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            self?.jumpToDate(picker.date)
        })
        present(sheet, animated: true)
    }

    private func jumpToDate(_ date: Date) {
        let calendar = Calendar.current
        let startOfSelected = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: timelineStartDate, to: startOfSelected).day ?? 0
        guard diff >= 0, diff < dates.count else { return }

        let previous = selectedIndex
        selectedIndex = diff
        var toReload = [IndexPath(item: selectedIndex, section: 0)]
        if previous != selectedIndex { toReload.append(IndexPath(item: previous, section: 0)) }
        collectionView.reloadItems(at: toReload)
        scrollTimelineToSelected(animated: true)
        filterRemindersForSelectedDate()
        filterEntriesForSelectedDate()
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func addJournalEntryTapped(_ sender: Any) {
        // Navigation handled by the storyboard segue "JournalEntryViewController".
        // onSave wiring happens in prepare(for:sender:) below.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JournalEntryViewController",
           let vc = segue.destination as? JournalEntryViewController {
            vc.onSave = { [weak self] entry in
                guard let self else { return }
                self.allJournalEntries.insert(entry, at: 0)
                self.saveEntries()
                self.filterEntriesForSelectedDate()
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }

    @IBAction func addReminderTapped(_ sender: UIButton) {
        print("Add Reminder Button Tapped")

        eventStore.requestFullAccessToEvents { granted, error in
            
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

    // MARK: - Date filtering

    private func date(forIndex index: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: index, to: timelineStartDate)
    }

    private func filterEntriesForSelectedDate() {
        guard let selectedDate = date(forIndex: selectedIndex) else {
            journalEntries = allJournalEntries
            return
        }
        let calendar = Calendar.current
        journalEntries = allJournalEntries.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }
        entriesExpanded = false
    }

    private func filterRemindersForSelectedDate() {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        let sorted = allReminders
            .filter { $0.startDate != nil }
            .sorted { $0.startDate! < $1.startDate! }

        guard let selectedDate = date(forIndex: selectedIndex) else {
            reminders = sorted.filter { $0.startDate! >= startOfToday }
            remindersExpanded = false
            return
        }

        if calendar.isDateInToday(selectedDate) {
            // Show all upcoming (today + future), sorted
            reminders = sorted.filter { $0.startDate! >= startOfToday }
        } else {
            // Show only reminders on that specific day
            reminders = sorted.filter { calendar.isDate($0.startDate!, inSameDayAs: selectedDate) }
        }
        remindersExpanded = false
    }

    // MARK: - Timeline generation
    private func generateTimelineDates() {
        dates.removeAll()
        days.removeAll()

        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = weekday - 1

        guard let thisSunday = calendar.date(
            byAdding: .day, value: -daysFromSunday, to: calendar.startOfDay(for: today)
        ) else { return }

        let weeksBack = 104   // 2 years of history
        let weeksForward = 12 // 3 months ahead

        guard let start = calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: thisSunday)
        else { return }
        timelineStartDate = start

        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "dd"
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "EEEEE"

        let totalDays = 7 * (weeksBack + weeksForward)
        for offset in 0..<totalDays {
            if let d = calendar.date(byAdding: .day, value: offset, to: start) {
                dates.append(formatterDate.string(from: d))
                days.append(formatterDay.string(from: d))
            }
        }

        todayIndex = weeksBack * 7 + daysFromSunday
        selectedIndex = todayIndex
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
        collectionView.alwaysBounceVertical = false

        collectionView.register(
            UINib(nibName: "TimelineCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: TimelineCollectionViewCell.reuseIdentifier
        )
    }

    // MARK: - Table setup
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)

        tableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderTableViewCell")
        tableView.register(UINib(nibName: "EntryCollectionViewCell", bundle: nil), forCellReuseIdentifier: "EntryCollectionViewCell")
    }

    // MARK: - Layout
    private func setupLayout() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            return self.generateTimelineSection()
        }
        collectionView.collectionViewLayout = layout
    }

    // MARK: - See More / See Less helpers
    private func visibleCount(for section: Int) -> Int {
        let total = section == 0 ? reminders.count : journalEntries.count
        let expanded = section == 0 ? remindersExpanded : entriesExpanded
        return expanded ? total : min(total, maxVisibleRows)
    }

    private func needsToggleButton(for section: Int) -> Bool {
        let total = section == 0 ? reminders.count : journalEntries.count
        return total > maxVisibleRows
    }

    @objc private func seeMoreTapped(_ sender: UIButton) {
        let section = sender.tag
        if section == 0 {
            remindersExpanded.toggle()
        } else {
            entriesExpanded.toggle()
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

// MARK: - Collection View (timeline only)
extension JournalViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

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

        cell.configure(
            day: days[indexPath.item],
            date: dates[indexPath.item],
            isToday: indexPath.item == todayIndex,
            isSelected: indexPath.item == selectedIndex
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath.item

        var toReload = [IndexPath(item: selectedIndex, section: 0)]
        if previous != selectedIndex {
            toReload.append(IndexPath(item: previous, section: 0))
        }
        collectionView.reloadItems(at: toReload)
        scrollTimelineToSelected(animated: true)
        filterRemindersForSelectedDate()
        filterEntriesForSelectedDate()
        tableView.reloadData()
    }
}

// MARK: - Table View (reminders + entries)
extension JournalViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return visibleCount(for: section)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "EntryCollectionViewCell", for: indexPath
            ) as! EntryCollectionViewCell
            cell.configure(entry: journalEntries[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ReminderTableViewCell", for: indexPath
            ) as! ReminderTableViewCell
            cell.configure(with: reminders[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("SectionHeaderView", owner: nil)?.first as! SectionHeaderView
        if section == 0 {
            header.configure(title: "Reminders", subtitle: remindersHeaderSubtitle())
        } else {
            header.configure(title: "My Entries", subtitle: selectedDateLabel())
        }
        return header
    }

    private func remindersHeaderSubtitle() -> String {
        guard let selectedDate = date(forIndex: selectedIndex) else {
            return reminders.isEmpty ? "No upcoming reminders" : "All upcoming"
        }
        if Calendar.current.isDateInToday(selectedDate) {
            return reminders.isEmpty ? "No upcoming reminders" : "All upcoming"
        }
        // Specific date selected
        if reminders.isEmpty { return "No reminders on this day" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, d MMM"
        return fmt.string(from: selectedDate)
    }

    private func selectedDateLabel() -> String {
        guard let date = date(forIndex: selectedIndex) else { return "" }
        if Calendar.current.isDateInToday(date) { return "Today" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, d MMM"
        return fmt.string(from: date)
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat { 60 }

    // MARK: - Footer for See More / See Less
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        guard needsToggleButton(for: section) else { return nil }

        let expanded = section == 0 ? remindersExpanded : entriesExpanded

        let footer = UIView()
        footer.backgroundColor = .clear

        let button = UIButton(type: .system)
        button.setTitle(expanded ? "See Less" : "See More", for: .normal)
        button.setImage(nil, for: .normal)
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.tag = section
        button.addTarget(self, action: #selector(seeMoreTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        footer.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])
        return footer
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return needsToggleButton(for: section) ? 44 : 0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 1 ? 100 : 88
    }

    // Swipe left → Delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self else { return done(false) }
            if indexPath.section == 0 {
                let removed = self.reminders.remove(at: indexPath.row)
                self.cancelNotification(for: removed)
                self.allReminders.removeAll { $0 === removed }
                self.saveReminders()
                if self.reminders.count <= self.maxVisibleRows {
                    self.remindersExpanded = false
                }
            } else {
                let removed = self.journalEntries.remove(at: indexPath.row)
                self.allJournalEntries.removeAll { $0.id == removed.id }
                self.saveEntries()
                if self.journalEntries.count <= self.maxVisibleRows {
                    self.entriesExpanded = false
                }
            }
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { _ in
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            })
            done(true)
        }
        action.image = UIImage(systemName: "trash")
        action.backgroundColor = UIColor(red: 0.93, green: 0.45, blue: 0.45, alpha: 1)
        return UISwipeActionsConfiguration(actions: [action])
    }

    // Tap entry → show notes
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let entry = journalEntries[indexPath.row]
        let vc = NotesEditorViewController()
        vc.initialText = entry.note
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Timeline layout section
extension JournalViewController {

    func generateTimelineSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(88)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .zero
        return section
    }
}

// MARK: - Event Delegate
extension JournalViewController: EKEventEditViewDelegate {

    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
        guard action == .saved, let event = controller.event else { return }

        let startOfToday = Calendar.current.startOfDay(for: Date())
        if let startDate = event.startDate, startDate < startOfToday {
            let alert = UIAlertController(
                title: "Invalid Date",
                message: "Reminders can only be set for today or a future date.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        try? eventStore.remove(event, span: .thisEvent)
        scheduleNotification(for: event)
        allReminders.append(event)
        saveReminders()
        filterRemindersForSelectedDate()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// MARK: - Notifications
extension JournalViewController {

    private func notificationID(for event: EKEvent) -> String {
        let ts = event.startDate.map { String($0.timeIntervalSince1970) } ?? "0"
        return "reminder_\(event.title ?? "")_\(ts)"
    }

    func scheduleNotification(for event: EKEvent) {
        guard let startDate = event.startDate, startDate > Date().addingTimeInterval(-60) else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title ?? "Reminder"
        content.body = "You have a reminder scheduled."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: startDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationID(for: event),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for event: EKEvent) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID(for: event)])
    }
}

// MARK: - Persistence
extension JournalViewController {

    // Lightweight codable mirror of EKEvent (only fields we need)
    private struct PersistedReminder: Codable {
        let title: String
        let startDate: Date
    }

    // In DEBUG the files are written directly into the project's Model folder
    // so they appear in Xcode alongside data.json.
    // In Release they live in the app's sandboxed Documents directory.
    private static var modelDirectory: URL {
        #if DEBUG
        return URL(fileURLWithPath: #file)   // …/Journal/JournalViewController.swift
            .deletingLastPathComponent()      // …/Journal/
            .deletingLastPathComponent()      // …/skinCare/
            .appendingPathComponent("Model")  // …/Model/
        #else
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
    }

    private static var entriesFileURL: URL {
        modelDirectory.appendingPathComponent("journal_entries.json")
    }

    private static var remindersFileURL: URL {
        modelDirectory.appendingPathComponent("journal_reminders.json")
    }

    func saveEntries() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(allJournalEntries) {
            try? data.write(to: Self.entriesFileURL)
        }
    }

    func saveReminders() {
        let persisted = allReminders.compactMap { event -> PersistedReminder? in
            guard let date = event.startDate else { return nil }
            return PersistedReminder(title: event.title ?? "", startDate: date)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(persisted) {
            try? data.write(to: Self.remindersFileURL)
        }
    }

    private func loadPersistedData() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Load entries
        if let data = try? Data(contentsOf: Self.entriesFileURL),
           let entries = try? decoder.decode([JournalEntry].self, from: data) {
            allJournalEntries = entries
        }

        // Load reminders — reconstruct EKEvent objects from stored data
        if let data = try? Data(contentsOf: Self.remindersFileURL),
           let persisted = try? decoder.decode([PersistedReminder].self, from: data) {
            allReminders = persisted.map { p in
                let event = EKEvent(eventStore: eventStore)
                event.title = p.title
                event.startDate = p.startDate
                event.endDate = p.startDate.addingTimeInterval(3600)
                return event
            }
        }
    }
}


