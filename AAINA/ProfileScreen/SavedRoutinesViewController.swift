import UIKit

class SavedRoutinesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var routines: [SavedRoutine] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Empty State
    private let emptyContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bookmark.slash"))
        iv.tintColor = UIColor.systemPink.withAlphaComponent(0.4)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitle: UILabel = {
        let l = UILabel()
        l.text = "No saved routines yet"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitle: UILabel = {
        let l = UILabel()
        l.text = "Your AI-generated routines will\nappear here once you save them."
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .systemGray
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Routines"
        view.applyAINABackground()
        setupTableView()
        setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        routines = AppDataModel.shared.savedRoutines.sorted { $0.createdAt > $1.createdAt }
        tableView.reloadData()
        emptyContainer.isHidden = !routines.isEmpty
        tableView.isHidden = routines.isEmpty
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SavedRoutineCell.self, forCellReuseIdentifier: "SavedRoutineCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyContainer.addSubview(emptyIcon)
        emptyContainer.addSubview(emptyTitle)
        emptyContainer.addSubview(emptySubtitle)
        view.addSubview(emptyContainer)

        NSLayoutConstraint.activate([
            emptyContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            emptyIcon.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 64),
            emptyIcon.heightAnchor.constraint(equalToConstant: 64),

            emptyTitle.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 16),
            emptyTitle.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyTitle.leadingAnchor.constraint(equalTo: emptyContainer.leadingAnchor),
            emptyTitle.trailingAnchor.constraint(equalTo: emptyContainer.trailingAnchor),

            emptySubtitle.topAnchor.constraint(equalTo: emptyTitle.bottomAnchor, constant: 8),
            emptySubtitle.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptySubtitle.leadingAnchor.constraint(equalTo: emptyContainer.leadingAnchor),
            emptySubtitle.trailingAnchor.constraint(equalTo: emptyContainer.trailingAnchor),
            emptySubtitle.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor)
        ])
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRoutineCell", for: indexPath) as! SavedRoutineCell
        cell.configure(with: routines[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self else { return }
            let id = self.routines[indexPath.row].id
            AppDataModel.shared.deleteSavedRoutine(id: id)
            self.routines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.emptyContainer.isHidden = !self.routines.isEmpty
            self.tableView.isHidden = self.routines.isEmpty
            done(true)
        }
        delete.backgroundColor = UIColor.systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Saved Routine Cell

private class SavedRoutineCell: UITableViewCell {

    private let card = UIView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let badgeLabel = UILabel()
    private let productsLabel = UILabel()
    private let metaLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        buildLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        // Card
        card.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // Badge (skin type pill)
        badgeLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        badgeLabel.textColor = .systemPink
        badgeLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(0.12)
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center

        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2

        // Date
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .systemGray

        // Products
        productsLabel.font = UIFont.systemFont(ofSize: 13)
        productsLabel.textColor = .systemGray
        productsLabel.numberOfLines = 2

        // Meta (steps · Morning · Evening)
        metaLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        metaLabel.textColor = UIColor.systemPink

        // Chevron
        chevron.tintColor = .systemGray3
        chevron.contentMode = .scaleAspectFit

        for v in [nameLabel, dateLabel, badgeLabel, productsLabel, metaLabel, chevron] {
            v.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(v)
        }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Badge
            badgeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            badgeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),

            // Name
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: badgeLabel.leadingAnchor, constant: -8),

            // Date
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            // Products
            productsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            productsLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            productsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            // Divider / separator handled by spacing only

            // Meta
            metaLabel.topAnchor.constraint(equalTo: productsLabel.bottomAnchor, constant: 12),
            metaLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            metaLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            // Chevron
            chevron.centerYAnchor.constraint(equalTo: metaLabel.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with routine: SavedRoutine) {
        nameLabel.text = routine.name

        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM yyyy"
        dateLabel.text = "Saved \(fmt.string(from: routine.createdAt))"

        // Skin type badge from saved profile
        let skinType = AppDataModel.shared.userProfile?.dominantSkinType.rawValue.capitalized ?? "Custom"
        badgeLabel.text = "  \(skinType)  "

        // Top products from steps
        let allProducts = (routine.morning + routine.evening).prefix(3).map { $0.productName }
        productsLabel.text = allProducts.joined(separator: "  ·  ")

        // Step count and timing
        let totalSteps = routine.morning.count + routine.evening.count
        var timing: [String] = []
        if !routine.morning.isEmpty { timing.append("Morning") }
        if !routine.evening.isEmpty { timing.append("Evening") }
        metaLabel.text = "\(totalSteps) steps  ·  " + timing.joined(separator: " · ")
    }
}
