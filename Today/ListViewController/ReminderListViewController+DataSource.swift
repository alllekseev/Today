//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit

extension ReminderListViewController {
    // TODO: - изучить diffable data source
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>

    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }

    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }

    func updateSnashot(reloading ids: [Reminder.ID] = []) {
        var snashot = Snapshot()
        snashot.appendSections([0])
        snashot.appendItems(reminders.map { $0.id })
        if !ids.isEmpty {
            snashot.reloadItems(ids)
        }
        dataSource.apply(snashot)
    }

    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
        // TODO: - разобраться с indexPath.item
        let reminder = reminder(withId: id)
        var contentConfiguration = cell.defaultContentConfiguration()

        // MARK: Cell's Content
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dateAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration

        // MARK: Cell's Button
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint

        // MARK: Accessibility Properties
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue

        // MARK: Cell's Accessories
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed: .always)
        ]

        // MARK: Cell's Background
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
    }

    func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(withId: id)
        return reminders[index]
    }

    func updateReminder(_ reminder: Reminder) {
        let index = reminders.indexOfReminder(withId: reminder.id)
        reminders[index] = reminder
    }

    func completeReminder(withId id: Reminder.ID) {
        var reminder = reminder(withId: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnashot()
        updateSnashot(reloading: [id])
    }

    func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accessibility label")
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(withId: reminder.id)
            return true
        }
        return action
    }

    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        // TODO: change string value on Enum
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(
            systemName: symbolName,
            withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(
            customView: button,
            placement: .leading(displayed: .always))
    }
}
