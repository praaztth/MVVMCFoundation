//
//  File.swift
//  MVVMCFoundation
//
//  Created by катенька on 18.07.2025.
//

import Foundation
import UIKit
import SwiftHelper

public class PaywallView: UIView {
    public struct Configuration {
        let backgroundImage: UIImage
        let title: String
        let titleFont: UIFont
        let buttonText: String
        let buttonCornerRadius: CGFloat
        let textColor: UIColor
        let tintColor: UIColor
        let descriptionStrings: [String]?
        let descriptionImage: UIImage?
        let descriptionHeight: CGFloat?
        let closeButtonColor: UIColor
        let plainButtonsColor: UIColor
        let gradientColor: UIColor
        
        public init(backgroundImage: UIImage, title: String, titleFont: UIFont, buttonText: String, buttonCornerRadius: CGFloat, textColor: UIColor, tintColor: UIColor, descriptionStrings: [String]?, descriptionImage: UIImage?, descriptionHeight: CGFloat?, closeButtonColor: UIColor, plainButtonsColor: UIColor, gradientColor: UIColor) {
            self.backgroundImage = backgroundImage
            self.title = title
            self.titleFont = titleFont
            self.buttonText = buttonText
            self.buttonCornerRadius = buttonCornerRadius
            self.textColor = textColor
            self.tintColor = tintColor
            self.descriptionStrings = descriptionStrings
            self.descriptionImage = descriptionImage
            self.descriptionHeight = descriptionHeight
            self.closeButtonColor = closeButtonColor
            self.plainButtonsColor = plainButtonsColor
            self.gradientColor = gradientColor
        }
    }
    
    public struct PaywallProductModel {
        public let title: String
        public let price: String
        public let description: String
        public let period: String
        
        public init(title: String, price: String, description: String, period: String) {
            self.title = title
            self.price = price
            self.description = description
            self.period = period
        }
    }
    
    var gradientView = GradientView()
    let backgroundImageView = SwiftHelper.uiHelper.customImageView(image: UIImage(), isClipped: true, mode: .scaleAspectFill, cornerRadius: nil, borderWidth: nil, borderColor: nil)
    let titleLabel = SwiftHelper.uiHelper.customLabel(text: "", font: .systemFont(ofSize: 29), color: .label, textAligment: nil, numberLines: 0)
    let descriptionViewStack = UIStackView()
    public let optionButtonsStack = UIStackView()
    public let closeButton = UIButton()
    public let subscribeButton = UIButton()
    public let termsOfUseButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .clear, bgImage: nil, title: "Terms of Use", titleColor: UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1), fontTitleColor: .systemFont(ofSize: 12, weight: .regular), cornerRadius: nil, borderWidth: nil, borderColor: nil)
    public let restorePurchasesButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .clear, bgImage: nil, title: "Restore Purshases", titleColor: UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1), fontTitleColor: .systemFont(ofSize: 12, weight: .regular), cornerRadius: nil, borderWidth: nil, borderColor: nil)
    public let privacyPolicyButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .clear, bgImage: nil, title: "Privacy Policy", titleColor: UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1), fontTitleColor: .systemFont(ofSize: 12, weight: .regular), cornerRadius: nil, borderWidth: nil, borderColor: nil)
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        setupBackgroundImageView()
        setupGradientView()
        setupTitleLabel()
        setupDescriptionViewStack()
        setupOptionButtonsStack()
        setupSubscribeButton()
        setupFooterButtons()
        setupCloseButton()
        setupConstraints()
    }
    
    public func configure(with configuration: Configuration) {
        titleLabel.text = configuration.title
        titleLabel.textColor = configuration.textColor
        titleLabel.font = configuration.titleFont
        
        configuration.descriptionStrings?.forEach { string in
            let view = getDescriptionItem(text: string, image: configuration.descriptionImage, color: configuration.textColor)
            descriptionViewStack.addArrangedSubview(view)
        }
        if let height = configuration.descriptionHeight {
            descriptionViewStack.snp.makeConstraints { make in
                make.height.equalTo(height)
            }
        }
        
        closeButton.tintColor = configuration.closeButtonColor
        backgroundImageView.image = configuration.backgroundImage
        subscribeButton.setTitleColor(configuration.textColor, for: .normal)
        subscribeButton.backgroundColor = configuration.tintColor
        subscribeButton.setTitle(configuration.buttonText, for: .normal)
        subscribeButton.layer.cornerRadius = configuration.buttonCornerRadius
        
        
        gradientView.setGradient(colors: [configuration.gradientColor.withAlphaComponent(0).cgColor, configuration.gradientColor.cgColor])
        
        [termsOfUseButton, restorePurchasesButton, privacyPolicyButton].forEach { button in
            button.setTitleColor(configuration.plainButtonsColor, for: .normal)
        }
    }
    
    func setupCloseButton() {
        addSubview(closeButton)
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.image = UIImage(systemName: "xmark")
        closeButton.configuration = config
        closeButton.animateButton()
        closeButton.isHidden = true
    }
    
    func setupGradientView() {
        addSubview(gradientView)
    }
    
    func setupBackgroundImageView() {
        addSubview(backgroundImageView)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
    }
    
    func setupDescriptionViewStack() {
        addSubview(descriptionViewStack)
        descriptionViewStack.axis = .vertical
        descriptionViewStack.spacing = 14
        descriptionViewStack.alignment = .leading
    }
    
    func setupOptionButtonsStack() {
        addSubview(optionButtonsStack)
        optionButtonsStack.axis = .vertical
        optionButtonsStack.spacing = 10
        optionButtonsStack.alignment = .fill
    }
    
    func setupSubscribeButton() {
        addSubview(subscribeButton)
        subscribeButton.clipsToBounds = true
        subscribeButton.animateButton()
    }
    
    func setupFooterButtons() {
        [
            termsOfUseButton,
            restorePurchasesButton,
            privacyPolicyButton
        ].forEach { button in
            addSubview(button)
        }
    }
    
    func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(descriptionViewStack.snp.top).offset(-18)
        }
        
        descriptionViewStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(optionButtonsStack.snp.top).offset(-32)
        }
        
        optionButtonsStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-20)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(restorePurchasesButton.snp.top)
            make.height.equalTo(62)
        }
        
        termsOfUseButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(restorePurchasesButton.snp.left)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        restorePurchasesButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        privacyPolicyButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(restorePurchasesButton.snp.right)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        gradientView.snp.makeConstraints { make in
            make.height.equalTo(147)
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(backgroundImageView)
            make.right.equalTo(backgroundImageView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.top.equalTo(safeAreaLayoutGuide)
            make.right.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
    
    func getDescriptionItem(text: String, image: UIImage?, color: UIColor) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = color
        label.text = text
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = color
        
        let view = UIView()
        view.addSubview(label)
        view.addSubview(imageView)
        
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.trailing.equalTo(view)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(label.snp.leading).offset(-6)
            make.height.width.equalTo(19)
        }
        
        return view
    }
}
