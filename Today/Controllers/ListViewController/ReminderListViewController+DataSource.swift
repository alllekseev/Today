//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit

extension ReminderListViewController {
    
    // MARK: - Typealiases

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>

    // MARK: - Computed Properties

    private var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }

    private var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }

    private var reminderStore: ReminderStore { ReminderStore.shared }

    // MARK: - Update snaphot method

    func updateSnapshot(reloading idsThatChanged: [Reminder.ID] = []) {
        let ids = idsThatChanged.filter { id in filteredReminders.contains(where: { $0.id == id }) }
        var snashot = Snapshot()
        snashot.appendSections([0])
        snashot.appendItems(filteredReminders.map { $0.id })
        if !ids.isEmpty {
            snashot.reloadItems(ids)
        }
        dataSource.apply(snashot)
        headerView?.progress = progress
    }

    // MARK: - Cell Registration Handler

    func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        id: Reminder.ID
    ) {
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

    // MARK: - Work with reminder methods

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
        updateSnapshot()
        updateSnapshot(reloading: [id])
    }

    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }

    func deleteReminder(withId id: Reminder.ID) {
        let index = reminders.indexOfReminder(withId: id)
        reminders.remove(at: index)
    }

    // MARK: - Prepare Reminder Store

    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif
            } catch {
                showError(error)
            }
            updateSnapshot()
        }
    }

    // MARK: - Done Button's methods

    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString(
            "Toggle completion",
            comment: "Reminder done button accessibility label")
        let action = UIAccessibilityCustomAction(name: name) { [weak self] _ in
            self?.completeReminder(withId: reminder.id)
            return true
        }
        return action
    }

    // MARK: - Done Button Configuration

    private func doneButtonConfiguration(
        for reminder: Reminder
    ) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "checkmark.circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(
            systemName: symbolName,
            withConfiguration: symbolConfiguration)

        let button = ReminderDoneButton()
        button.id = reminder.id
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)

        return UICellAccessory.CustomViewConfiguration(
            customView: button,
            placement: .leading(displayed: .always))
    }
}
