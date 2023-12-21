//
//  ViewController.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit

final class ReminderListViewController: UICollectionViewController {

    // MARK: - Properties

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
    var headerView: ProgressHeaderView?
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        }
        return progress
    }

    // MARK: - Lifecycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .todayGradientFutureBegin

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

        let headerRegistration = UICollectionView.SupplementaryRegistration(
            elementKind: ProgressHeaderView.elementKind,
            handler: supplementaryRegistrationHandler
        )
        dataSource.supplementaryViewProvider = { _, _, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }

    // MARK: - Override CollectionView methods

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id  = filteredReminders[indexPath.item].id
        pushDetailViewForReminder(with: id)
        return false
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == ProgressHeaderView.elementKind,
              let progressView = view as? ProgressHeaderView else {
            return
        }

        progressView.progress = progress
    }

    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradienLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
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
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

    // MARK: - Configuration swipe action

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

    // MARK: - Supplementary Registration Handler

    private func supplementaryRegistrationHandler(
        progressView: ProgressHeaderView,
        elementKind: String,
        indexPath: IndexPath
    ) {
        headerView = progressView
    }

}
