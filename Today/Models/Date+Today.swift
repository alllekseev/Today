//
//  Date+Today.swift
//  Today
//
//  Created by Олег Алексеев on 29.11.2023.
//

import Foundation

extension Date {
    var dateAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened)
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }

    var dateText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        } else if Locale.current.calendar.isDateInYesterday(self) {
            let dateFormat = NSLocalizedString("Yesterday", comment: "Yesterday due date description")
            return String(format: dateFormat)
        } else if Locale.current.calendar.isDateInTomorrow(self) {
            let dateFormat = NSLocalizedString("Tomorrow", comment: "Tomorrow due date description")
            return String(format: dateFormat)
        } else {
            return formatted(.dateTime.month().day().weekday(.wide))
        }
    }
}
