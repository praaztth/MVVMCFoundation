//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 24.07.2025.
//

import UIKit
import SwiftHelper

public class BarButton: UIButton {
    public struct Configuration {
        let title: String?
        let font: UIFont?
        let image: UIImage?
        let tintColor: UIColor
        let backgroundColor: UIColor
        
        public init(title: String?, font: UIFont?, image: UIImage?, tintColor: UIColor, backgroundColor: UIColor) {
            self.title = title
            self.font = font
            self.image = image
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
        }
    }
    
    public init(configuration: Configuration) {
        super.init(frame: .zero)
        
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.image = configuration.image
        buttonConfiguration.baseForegroundColor = configuration.tintColor
        buttonConfiguration.baseBackgroundColor = configuration.backgroundColor
        buttonConfiguration.cornerStyle = .capsule
        if let title = configuration.title {
            var attrTitle = AttributedString(title)
            attrTitle.font = configuration.font ?? UIFont.systemFont(ofSize: 11, weight: .semibold)
            buttonConfiguration.attributedTitle = attrTitle
        }
        
        self.configuration = buttonConfiguration
        self.animateButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
