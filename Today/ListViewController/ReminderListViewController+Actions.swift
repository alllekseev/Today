//
//  ReminderListViewController+Actions.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import UIKit

extension ReminderListViewController {
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id)
    }
}
