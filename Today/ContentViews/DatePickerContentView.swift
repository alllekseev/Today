//
//  DatePickerContentView.swift
//  Today
//
//  Created by Олег Алексеев on 04.12.2023.
//

import UIKit

final class DatePickerContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        var date = Date.now

        func makeContentView() -> UIView & UIContentView {
            return DatePickerContentView(self)
        }

        func updated(for state: UIConfigurationState) -> Self {
            return self
        }
    }

    private var datePicker = UIDatePicker()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(datePicker)
        datePicker.preferredDatePickerStyle = .inline
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        datePicker.date = configuration.date
    }
}

extension UICollectionViewCell {
    func datePickerConfiguration() -> DatePickerContentView.Configuration {
        DatePickerContentView.Configuration()
    }
}
