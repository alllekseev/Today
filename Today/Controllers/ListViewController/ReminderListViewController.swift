//
//  ViewController.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit

final class ReminderListViewController: UICollectionViewController {

    // MARK: - ReminderListViewController properties

    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData
    var listStyle: ReminderListStyle = .today
    var filteredReminders: [Reminder] {
        return reminders.filter {
            listStyle.shouldInclude(date: $0.dueDate)
        }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    let listStyleSegmentedControll = UISegmentedControl(items: [
        ReminderListStyle.today.name,
        ReminderListStyle.future.name,
        ReminderListStyle.all.name,
    ])

    // MARK: - ReminderListViewController lifecycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout

        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        dataSource = DataSource(collectionView: collectionView) {
            (
                collectionView: UICollectionView,
                indexPath: IndexPath,
                itemIdentifier: Reminder.ID
            ) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didPressAddButton(_:))
        )
        addButton.accessibilityLabel = NSLocalizedString(
            "Add reminder",
            comment: "Add button accessibility label"
        )
        navigationItem.rightBarButtonItem = addButton

        listStyleSegmentedControll.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentedControll.addTarget(self, action: #selector(didChangeListStyle), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControll

        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }

        updateSnapshot()

        collectionView.dataSource = dataSource
    }

    // MARK: - Override CollectionView method

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id  = filteredReminders[indexPath.item].id
        pushDetailViewForReminder(with: id)
        return false
    }

    // MARK: - NavigationController method

    func pushDetailViewForReminder(with id: Reminder.ID) {
        let reminder = reminder(withId: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.updateReminder(reminder)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Configuration layout method

    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

    // MARK: - Configure swipe action

    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath,
              let id = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: deleteActionTitle
        ) { [weak self] _, _, completion in
            self?.deleteReminder(withId: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
