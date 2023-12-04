//
//  ReminderViewController+CellConfiguration.swift
//  Today
//
//  Created by Олег Алексеев on 04.12.2023.
//

import UIKit

extension ReminderViewController {

    // MARK: - Default configuration
    func defaultConfiguration(
        for cell: UICollectionViewListCell,
        at row: Row
    ) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        return contentConfiguration
    }

    func headerConfiguration(
        for cell: UICollectionViewListCell,
        with title: String
    ) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }

    func titleConfiguration(
        for cell: UICollectionViewCell,
        with title: String?
    ) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }

    func dateConfiguration(
        for cell: UICollectionViewListCell,
        with date: Date
    ) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datePickerConfiguration()
        contentConfiguration.date = date
        return contentConfiguration
    }

    func notesConfiguration(
        for cell: UICollectionViewListCell,
        with notes: String?
    ) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = notes
        return contentConfiguration
    }

    // MARK: - Row's Style Text

    func text(for row: Row) -> String? {
        switch row {
        case .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        default: return nil
        }
    }
}