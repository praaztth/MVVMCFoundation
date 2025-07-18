//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 16.07.2025.
//

import Foundation
import UIKit
import SnapKit

public final class EnterPromptView: UIView {
    public struct Configuration {
        let placeholderText: String
        let labelFont: UIFont
        let textViewFont: UIFont
        let backgroundColor: UIColor
        let placeholderColor: UIColor
        let cornerRadius: CGFloat
        
        public init(placeholderText: String, labelFont: UIFont, textViewFont: UIFont, backgroundColor: UIColor, placeholderColor: UIColor, cornerRadius: CGFloat) {
            self.placeholderText = placeholderText
            self.labelFont = labelFont
            self.textViewFont = textViewFont
            self.backgroundColor = backgroundColor
            self.placeholderColor = placeholderColor
            self.cornerRadius = cornerRadius
        }
    }
    
    let titleLabel = UILabel()
    public let textView = UITextView()
    
    var placeholderText: String = ""
    var placeholderColor: UIColor = .white
    public var text: String {
        textView.text == placeholderText && textView.textColor == placeholderColor ? "" : textView.text
    }
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        setupTitleLabel()
        setupTextView()
        setupConstraints()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.text = "Enter Promt"
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
    }
    
    func setupTextView() {
        addSubview(textView)
        textView.backgroundColor = .clear
        textView.textColor = .white
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.bottom.equalToSuperview().inset(-14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    public func configure(with configuration: Configuration) {
        self.placeholderText = configuration.placeholderText
        titleLabel.font = configuration.labelFont
        textView.font = configuration.textViewFont
        self.placeholderColor = configuration.placeholderColor
        backgroundColor = configuration.backgroundColor
        layer.cornerRadius = configuration.cornerRadius
        
        setPlacehoderState()
    }
    
    public func clearText() {
        textView.text = ""
        setPlacehoderState()
    }
    
    public func setPlacehoderState() {
        if textView.text == "" {
            textView.text = self.placeholderText
            textView.textColor = self.placeholderColor
        }
    }
    
    public func removePlacehoderState() {
        if textView.text == self.placeholderText && textView.textColor == self.placeholderColor {
            textView.text = ""
            textView.textColor = .white
        }
    }
}
