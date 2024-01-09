//
//  UIView+DebugOutline.swift
//  Today
//
//  Created by Олег Алексеев on 22.12.2023.
//

import UIKit

extension UIView {
    func debugOutline(with borderColor: UIColor = .red, and borderWidth: CGFloat = 1.0) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}
