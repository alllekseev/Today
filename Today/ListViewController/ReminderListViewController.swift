//
//  ViewController.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit
// TODO: make all classes final access
class ReminderListViewController: UICollectionViewController {
    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData

    override func viewDidLoad() {
        super.viewDidLoad()

        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout

        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        dataSource = DataSource(
            collectionView: collectionView
        ) {
            (
                collectionView: UICollectionView,
                indexPath: IndexPath,
                itemIdentifier: Reminder.ID
            ) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }

        updateSnashot()

        collectionView.dataSource = dataSource
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id  = reminders[indexPath.item].id
        pushDetailViewForReminder(with: id)
        return false
    }

    func pushDetailViewForReminder(with id: Reminder.ID) {
        let reminder = reminder(withId: id)
        let viewController = ReminderViewController(reminder: reminder)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

}

