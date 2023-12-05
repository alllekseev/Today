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

        updateSnapshot()

        collectionView.dataSource = dataSource
    }

    // MARK: - Override CollectionView method

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id  = reminders[indexPath.item].id
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
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

}
