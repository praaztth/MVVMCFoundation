//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 21.07.2025.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat(redInt)/255.0,
            green: CGFloat(greenInt)/255.0,
            blue: CGFloat(blueInt)/255.0,
            alpha: alpha
        )
    }
}
