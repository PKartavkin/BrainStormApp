//
//  UIBarButton+Extension.swift
//  BrainStormApp
//
//  Created by Hristiyan Zahariev on 2.09.18.
//

import Foundation
import UIKit

extension UIBarButtonItem {

    var isHidden: Bool {
        get {
            return tintColor == .clear
        }
        set {
            tintColor = newValue ? .clear : .white //or whatever color you want
            isEnabled = !newValue
            isAccessibilityElement = !newValue
        }
    }

}
