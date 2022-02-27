//
//  AlertView.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import UIKit

class AlertView: UIView, BaseView {
    
    let containerView = UIView()
    let messageLabel = CustomLabel(text: "message message", textSize: 13, textColor: .appRed, fontName: .MontserratMedium)
    let errorImageView = UIImageView()
    
    let titleLabel = UILabel()
    let buttonsStackView = UIStackView()
    let firstButton = UIButton()
    let secondButton = UIButton()
    
    var alertViewState: AlertViewState?
    
    init(title: String, message: String, rightButtonText: String, leftButtonText: String) {
        super.init(frame: .zero)
        alertViewState = .twoButtons
        titleLabel.text = title
        messageLabel.text = message
        firstButton.setTitle(rightButtonText, for: .normal)
        secondButton.setTitle(leftButtonText, for: .normal)
        buttonsStackView.addArrangedSubview(secondButton)
        buttonsStackView.addArrangedSubview(firstButton)
        setupView()
    }
    
    init(title: String, message: String, firstButtonText: String) {
        super.init(frame: .zero)
        alertViewState = .oneButton
        titleLabel.text = title
        messageLabel.text = message
        firstButton.setTitle(firstButtonText, for: .normal)
        buttonsStackView.addArrangedSubview(firstButton)
        setupView()
    }
    
    init(message: String) {
        super.init(frame: .zero)
        alertViewState = .justMessage
        messageLabel.text = message
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func addSubviews() {
        
        guard let alertViewState = alertViewState else { return }
        
        switch(alertViewState) {
            
        case .justMessage:
            containerView.addSubview(messageLabel)
            containerView.addSubview(errorImageView)
            
        default:
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
            containerView.addSubview(buttonsStackView)
        }
        
        addSubview(containerView)
    }
    
    func styleSubviews() {
        
        backgroundColor = .gray.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    
        guard let alertViewState = alertViewState else { return }

        switch(alertViewState) {
            
        case .justMessage:
            containerView.backgroundColor = .errorRedLight
            errorImageView.image = UIImage(named: "error")
            
        default:
            containerView.backgroundColor = .whiteAndDarkBackground
            
            titleLabel.textAlignment = .center
            
            messageLabel.numberOfLines = 0
            messageLabel.textColor = .textTertiary
            messageLabel.textAlignment = .center
            
            buttonsStackView.axis = .horizontal
            buttonsStackView.spacing = 0
            buttonsStackView.distribution = .fillEqually
        
            buttonsStackView.layer.borderColor = UIColor.textTertiary.cgColor
            buttonsStackView.layer.borderWidth = 0.5
            
            firstButton.setTitleColor(.primaryColor, for: .normal)
            firstButton.titleLabel?.customFont(name: .MontserratSemiBold)
            
            secondButton.setTitleColor(.textTertiary, for: .normal)
            secondButton.titleLabel?.customFont(name: .MontserratMedium)
        
        }
       }
    
    func positionSubviews() {
        
        guard let alertViewState = alertViewState else { return }
        
        switch(alertViewState) {
            
        case .justMessage:
            containerView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 60, left: 20, bottom: 0, right: 20))
            containerView.constrainHeight(35)
            
            errorImageView.anchor(leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0), size: CGSize(width: 20, height: 20))
            errorImageView.centerYToSuperview()
            
            messageLabel.anchor(leading: errorImageView.trailingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            messageLabel.centerYToSuperview()
            
        case .oneButton, .twoButtons:
            containerView.constrainHeight(134)
            containerView.constrainWidth(210)
            containerView.centerXToSuperview()
            containerView.centerYToSuperview()
            
            titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8))
            titleLabel.constrainHeight(20)
            
            messageLabel.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: buttonsStackView.topAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            
            buttonsStackView.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: -1, bottom: -1, right: -1))
            buttonsStackView.constrainHeight(40)
        }
    }
}

enum AlertViewState {
    case justMessage
    case oneButton
    case twoButtons
}
