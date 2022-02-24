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
    
    let labelWithIcon = CustomLabel(text: "labelwithicon")
    let titleLabel = UILabel()
    let buttonsStackView = UIStackView()
    let firstButton = MainButton()
    let secondButton = MainButton()
    
    var alertViewState: AlertViewState?
    
    init(title: String, message: String, firstButtonText: String, secondButtonText: String) {
        super.init(frame: .zero)
        alertViewState = .twoButtons
        titleLabel.text = title
        messageLabel.text = message
        firstButton.setTitle(firstButtonText, for: .normal)
        secondButton.setTitle(secondButtonText, for: .normal)
        buttonsStackView.addArrangedSubview(firstButton)
        buttonsStackView.addArrangedSubview(secondButton)
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
    
    init(title: String, message: String?) {
        super.init(frame: .zero)
        alertViewState = .noButtons
        titleLabel.text = title
        messageLabel.text = message
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
            
        case .noButtons:
            containerView.addSubview(labelWithIcon)
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
        default:
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
            containerView.addSubview(buttonsStackView)
        }
        
        addSubview(containerView)
    }
    
    func styleSubviews() {
        
        backgroundColor = .gray.withAlphaComponent(0.5)
    
        guard let alertViewState = alertViewState else { return }

        switch(alertViewState) {
            
        case .justMessage:
            containerView.backgroundColor = .errorRedLight
            errorImageView.image = UIImage(named: "error")
            
        case .noButtons:
            containerView.backgroundColor = .errorRedLight
            
        default:
            containerView.backgroundColor =
            UIColor(red: 50.0 / 255.0, green: 49.0 / 255.0, blue: 49.0 / 255.0, alpha: 1)
            
            buttonsStackView.axis = .horizontal
            buttonsStackView.spacing = 0
            buttonsStackView.distribution = .fillEqually
            
            buttonsStackView.layer.borderColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 97.0 / 255.0, alpha: 1).cgColor
            buttonsStackView.layer.borderWidth = 1
            
            firstButton.layer.borderWidth = 0
            firstButton.layer.borderColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 97.0 / 255.0, alpha: 1).cgColor
//            firstButton.backgroundColor = .alertFirstButtonBackground
            firstButton.backgroundColor = UIColor(red: 50.0 / 255.0, green: 49.0 / 255.0, blue: 49.0 / 255.0, alpha: 1)
            firstButton.setTitleColor(UIColor(red: 0.0 / 255.0, green: 182.0 / 255.0, blue: 207.0 / 255.0, alpha: 1), for: .normal)
            
//            secondButton.layer.borderWidth = 1
            secondButton.layer.borderColor = UIColor(red: 98.0 / 255.0, green: 97.0 / 255.0, blue: 97.0 / 255.0, alpha: 1).cgColor
            secondButton.backgroundColor = UIColor(red: 50.0 / 255.0, green: 49.0 / 255.0, blue: 49.0 / 255.0, alpha: 1)
            secondButton.setTitleColor(UIColor(red: 0.0 / 255.0, green: 182.0 / 255.0, blue: 207.0 / 255.0, alpha: 1), for: .normal)
        
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
            
        case .noButtons:
            containerView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 60, left: 26, bottom: 0, right: 24))
            containerView.constrainHeight(90)
            
            labelWithIcon.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            labelWithIcon.constrainHeight(30)
            
            titleLabel.anchor(top: labelWithIcon.bottomAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 18, bottom: 0, right: 0))
            
            messageLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor,    trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            
        case .oneButton:
            containerView.constrainHeight(134)
            containerView.constrainWidth(290)
            containerView.centerXToSuperview()
            containerView.centerYToSuperview(offset: -65)
            
            titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
            
            messageLabel.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
            
            buttonsStackView.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: -1, bottom: -1, right: -1))
            buttonsStackView.constrainHeight(40)
            
        case .twoButtons:
            containerView.constrainHeight(134)
            containerView.constrainWidth(290)
            containerView.centerXToSuperview()
            containerView.centerYToSuperview(offset: -65)
            
            titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
            
            messageLabel.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
            
            buttonsStackView.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: -1, bottom: -1, right: -1))
            buttonsStackView.constrainHeight(40)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let alertViewState = alertViewState else {
            return
        }
        switch alertViewState {
        case .justMessage:
            containerView.roundCorners(corners: .allCorners, radius: 10)
        case .noButtons:
            containerView.roundCorners(corners: [.topRight, .topLeft], radius: 2.0)
            containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4.0)
        case .oneButton:
            containerView.roundCorners(corners: [.allCorners], radius: 4.0)
        case .twoButtons:
            containerView.roundCorners(corners: [.allCorners], radius: 4.0)
        }
        
    }
}

enum AlertViewState {
    case noButtons
    case oneButton
    case twoButtons
    case justMessage
}
