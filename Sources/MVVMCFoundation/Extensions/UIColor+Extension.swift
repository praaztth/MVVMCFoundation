//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 21.07.2025.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat(red)/255.0,
            green: CGFloat(green)/255.0,
            blue: CGFloat(blue)/255.0,
            alpha: alpha
        )
    }
}
