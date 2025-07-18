//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import UIKit
import SwiftHelper

public class InputImageView: UIImageView {
    public struct Configuration {
        let text: String
        let textColor: UIColor
        let icon: UIImage
        let cornerRadius: CGFloat
        let backgroundColor: UIColor
        let borderColor: UIColor
        let iconHeight: CGFloat
        
        public init(text: String, textColor: UIColor, icon: UIImage, cornerRadius: CGFloat, backgroundColor: UIColor, borderColor: UIColor, iconHeight: CGFloat) {
            self.text = text
            self.textColor = textColor
            self.icon = icon
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.iconHeight = iconHeight
        }
    }
    
    let emptyStackView = UIStackView()
    let iconImageView = UIImageView()
    let textLabel = UILabel()
    let dashedBorder = CAShapeLayer()
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with configuration: Configuration) {
        textLabel.text = configuration.text
        textLabel.textColor = configuration.textColor
        iconImageView.tintColor = configuration.textColor
        iconImageView.image = configuration.icon
        layer.cornerRadius = configuration.cornerRadius
        backgroundColor = configuration.backgroundColor
        dashedBorder.strokeColor = configuration.borderColor.cgColor
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(configuration.iconHeight)
        }
    }
    
    func setupUI() {
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        isUserInteractionEnabled = true
        
        setupDashedBorder()
        setupEmptyStackView()
        setupConstraints()
    }
    
    func setupDashedBorder() {
        dashedBorder.lineDashPattern = [4, 4]
        dashedBorder.fillColor = nil
        dashedBorder.lineWidth = 1
    }
    
    func setupEmptyStackView() {
        addSubview(emptyStackView)
        emptyStackView.axis = .vertical
        emptyStackView.distribution = .fill
        emptyStackView.alignment = .center
        emptyStackView.spacing = 10
        
        iconImageView.contentMode = .scaleAspectFit
        textLabel.numberOfLines = 0
        
        emptyStackView.addArrangedSubview(iconImageView)
        emptyStackView.addArrangedSubview(textLabel)
    }
    
    func setupConstraints() {
        emptyStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
    }
    
    public func setImage(_ image: UIImage) {
        self.image = image
        emptyStackView.isHidden = true
        if let index = layer.sublayers?.firstIndex(where: { $0 == dashedBorder }) {
            layer.sublayers?.remove(at: index)
        }
    }
    
    public func removeImage() {
        self.image = nil
        emptyStackView.isHidden = false
        setBorderLayout()
    }
    
    public func setBorderLayout() {
        layer.addSublayer(dashedBorder)
        dashedBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        dashedBorder.frame = bounds
    }
    
    public func getTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer()
        addGestureRecognizer(tapGesture)
        return tapGesture
    }
}
