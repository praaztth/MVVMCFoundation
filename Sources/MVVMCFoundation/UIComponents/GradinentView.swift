//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 18.07.2025.
//

import UIKit

public class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    public init() {
        super.init(frame: .zero)
    }
    
    public convenience init(colors: [CGColor]) {
        self.init()
        setGradient(colors: colors)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setGradient(colors: [CGColor]) {
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.addSublayer(gradientLayer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
