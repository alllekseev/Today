//
//  ReminderViewController.swift
//  Today
//
//  Created by Олег Алексеев on 30.11.2023.
//

import UIKit

final class ReminderViewController: UICollectionViewController {

    // MARK: - Typealeases

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    private var reminder: Reminder
    private var dataSource: DataSource!

    // MARK: - Initializers

    init(reminder: Reminder) {
        self.reminder = reminder

        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false

        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)

        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReminderViewController using init(reminder:)")
    }

    // MARK: - ReminderViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        dataSource = DataSource(collectionView: collectionView) {
            (
                collectionView,
                indexPath,
                itemIdentifier
            ) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }

        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")

        updateSnapshotForViewing()
    }

    // MARK: - Cell Registration Handler

    private func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        row: Row
    ) {
        let section = section(for: indexPath)
        switch (section, row) {
        case (.view, _):
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = text(for: row)
            contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
            contentConfiguration.image = row.image
            cell.contentConfiguration = contentConfiguration
        default: fatalError("Unexpected combination of section and row.")
        }
        cell.tintColor = .todayPrimaryTint
    }

    // MARK: - Row's Style Text

    private func text(for row: Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        }
    }

    // MARK: - Update snapshot for editing

    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        dataSource.apply(snapshot)
    }

    // MARK: - Update snapshot for viewing
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([Row.title, Row.date, Row.time, Row.notes], toSection: .view)
        dataSource.apply(snapshot)
    }

    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
        }
        return section
    }
}
