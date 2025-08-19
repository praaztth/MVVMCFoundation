//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 18.07.2025.
//

import Foundation
import UIKit
import SwiftHelper

public class PaywallProductButton: UIButton {
    public override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    var unselectedColor: UIColor!
    var selectedColor: UIColor!
    var selectedBorderWidth: CGFloat!
    var unselectedBorderWidth: CGFloat!
    
    var leftView: UIView!
    var rightView: UIView!
    
    let circleView = UIView()
    
    let bigCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.5
        return view
    }()
    
    let smallCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7
        return view
    }()
    
    public init(leftTitle: String, leftDescription: String, rightTitle: String, rightDescription: String, tintColor: UIColor, secondColor: UIColor, backgroundColor: UIColor, titleFont: UIFont? = nil, subtitleFont: UIFont? = nil, selectedBorderWidth: CGFloat = 1.5, unselectedBorderWidth: CGFloat = 0) {
        super.init(frame: .zero)
        setupViews(leftTitle: leftTitle, leftDescription: leftDescription, rightTitle: rightTitle, rightDescription: rightDescription, tintColor: tintColor, secondColor: secondColor, backgroundColor: backgroundColor, titleFont: titleFont, subtitleFont: subtitleFont, selectedBorderWidth: selectedBorderWidth, unselectedBorderWidth: unselectedBorderWidth)
        activateConstraints()
        updateAppearance()
        
        addTarget(self, action: #selector(toggleChanged), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(leftTitle: String, leftDescription: String, rightTitle: String, rightDescription: String, tintColor: UIColor, secondColor: UIColor, backgroundColor: UIColor, titleFont: UIFont?, subtitleFont: UIFont?, selectedBorderWidth: CGFloat, unselectedBorderWidth: CGFloat) {
        layer.cornerRadius = 16
        self.backgroundColor = backgroundColor
        bigCircle.layer.borderColor = tintColor.cgColor
        smallCircle.backgroundColor = backgroundColor
        layer.borderColor = tintColor.cgColor
        
        self.unselectedColor = secondColor
        self.selectedColor = tintColor
        self.selectedBorderWidth = selectedBorderWidth
        self.unselectedBorderWidth = unselectedBorderWidth
        
        leftView = verticalLabelsView(title: leftTitle, subtitle: leftDescription, textAligment: .left, titleFont: titleFont, subtitleFont: subtitleFont, titleColor: tintColor)
        rightView = verticalLabelsView(title: rightTitle, subtitle: rightDescription, textAligment: .right, titleFont: titleFont, subtitleFont: subtitleFont, titleColor: tintColor)
        
        circleView.isUserInteractionEnabled = false
        bigCircle.isUserInteractionEnabled = false
        smallCircle.isUserInteractionEnabled = false
        smallCircle.backgroundColor = self.selectedColor
        circleView.addSubview(bigCircle)
        circleView.addSubview(smallCircle)
        
        addSubview(leftView)
        addSubview(rightView)
        addSubview(circleView)
    }
    
    func activateConstraints() {
        leftView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        rightView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(circleView.snp.leading).offset(-24)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        bigCircle.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        smallCircle.snp.makeConstraints { make in
            make.center.equalTo(bigCircle)
            make.height.width.equalTo(14)
        }
    }
    
    func updateAppearance() {
        if isSelected {
            bigCircle.layer.borderColor = self.selectedColor.cgColor
            smallCircle.isHidden = false
            layer.borderWidth = self.selectedBorderWidth
        } else {
            bigCircle.layer.borderColor = self.unselectedColor.cgColor
            smallCircle.isHidden = true
            layer.borderWidth = self.unselectedBorderWidth
        }
    }
    
    @objc func toggleChanged() {
        if !isSelected {
            isSelected.toggle()
            sendActions(for: .valueChanged)
        }
    }
    
    func verticalLabelsView(title: String, subtitle: String, textAligment: NSTextAlignment, titleFont: UIFont?, subtitleFont: UIFont?, titleColor: UIColor?) -> UIView {
        let titleLabel = SwiftHelper.uiHelper.customLabel(text: title, font: titleFont ?? .systemFont(ofSize: 18, weight: .bold), color: titleColor ?? .white, textAligment: textAligment, numberLines: 1)
        let subtitleLabel = SwiftHelper.uiHelper.customLabel(text: subtitle, font: subtitleFont ?? .systemFont(ofSize: 12, weight: .regular), color: titleColor ?? .white, textAligment: textAligment, numberLines: 1)
        
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-2)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        return view
    }
}
