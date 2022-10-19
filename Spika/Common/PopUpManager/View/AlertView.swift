//
//  AlertView.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import UIKit

protocol AlertViewDelegate: AnyObject {
    func alertView(_ alertView: AlertView, indexOfPressedVerticalButton value: Int)
    func alertView(_ alertView: AlertView, needDismiss value: Bool)
}

enum AlertViewState {
    case staticInfo
    case justMessage
    case justButtons
    case titleAndButtons
}

enum StaticInfoAlert {
    case copy
    case forward
    case favorite
    
    var description: String {
        switch self {
        case .copy:
            return "Copied"
        case .forward:
            return "Forwarded"
        case .favorite:
            return "Added to favorite"
        }
    }
}

class AlertView: UIView, BaseView {
    
    weak var delegate: AlertViewDelegate?
    let alertViewState: AlertViewState
    var startPosition: CGFloat?
    var endPosition: CGFloat?
    let staticChoice: StaticInfoAlert
    
    let containerView = UIView()
    let descriptionLabel = CustomLabel(text: "For copy and favorite", textSize: 11, textColor: .textSecondary, fontName: .MontserratMedium, alignment: .center)
    let messageLabel = CustomLabel(text: "message message", textSize: 13, textColor: .appRed, fontName: .MontserratMedium, alignment: .center)
    let imageView = UIImageView(image: UIImage(safeImage: .error))
    let titleLabel = CustomLabel(text: "u cant see me", textSize: 14, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
    let buttonsStackView = UIStackView()
    
    init(titleAndMessage: (title: String, message: String)?, orientation: NSLayoutConstraint.Axis, buttonTexts: [String]) {
        
        if let titleAndMessage = titleAndMessage {
            alertViewState = .titleAndButtons
            titleLabel.text = titleAndMessage.title
            messageLabel.text = titleAndMessage.message
        } else {
            alertViewState = .justButtons
        }
        staticChoice = .copy
        super.init(frame: .zero)
        
        for (i, text) in buttonTexts.enumerated() {
            let button = UIButton()
            button.constrainHeight(46)
            button.setTitle(text, for: .normal)
            button.addTarget(self, action: #selector(testis), for: .touchUpInside)
            button.setTitleColor(i == buttonTexts.count - 1 ? .red : .primaryColor, for: .normal)
            button.titleLabel?.font = .customFont(name: i == buttonTexts.count - 1 ? .MontserratMedium : .MontserratSemiBold)
            button.backgroundColor = .white
            buttonsStackView.addArrangedSubview(button)
        }
        buttonsStackView.axis = orientation
        setupView()
    }
    
    init(message: String) {
        alertViewState = .justMessage
        staticChoice   = .copy
        super.init(frame: .zero)
        
        messageLabel.text = message
        setupView()
        addGestures()
    }
    
    init(_ choice: StaticInfoAlert) {
        alertViewState = .staticInfo
        staticChoice = choice
        super.init(frame: .zero)
        setupView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.alertView(self, needDismiss: true)
        }
    }
    
    required init?(coder: NSCoder) {
        alertViewState = .justMessage
        staticChoice = .copy
        super.init(coder: coder)
    }
    
    @objc func testis(_ button: UIButton) {
        guard let index =  buttonsStackView.arrangedSubviews.firstIndex(of: button) else { return }
        delegate?.alertView(self, indexOfPressedVerticalButton: index)
    }
    
    func addSubviews() {
        
        switch(alertViewState) {
            
        case .justButtons:
            containerView.addSubview(buttonsStackView)
            
        case .justMessage:
            containerView.addSubview(messageLabel)
            containerView.addSubview(imageView)
            
        case .titleAndButtons:
            containerView.addSubview(titleLabel)
            containerView.addSubview(messageLabel)
            containerView.addSubview(buttonsStackView)
        case .staticInfo:
            containerView.addSubview(descriptionLabel)
            containerView.addSubview(imageView)
        }
        addSubview(containerView)
    }
    
    func styleSubviews() {
        
        backgroundColor = alertViewState == .justMessage ? .clear : .gray.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        messageLabel.numberOfLines = 0
        buttonsStackView.distribution = .fillEqually
        
        switch(alertViewState) {
            
        case .justMessage:
            containerView.backgroundColor = .errorRedLight
            messageLabel.textAlignment = .natural
            
        case .titleAndButtons, .justButtons:
            containerView.backgroundColor = .whiteAndDarkBackground
            buttonsStackView.backgroundColor = .gray
            buttonsStackView.spacing = 0.25
            buttonsStackView.layer.borderWidth = 0.25
            buttonsStackView.layer.borderColor = UIColor.gray.cgColor
        case .staticInfo:
            containerView.backgroundColor = .whiteAndDarkBackground
            imageView.image = UIImage(safeImage: .sent)
            descriptionLabel.text = staticChoice.description
        }
    }
    
    func positionSubviews() {
        
        switch(alertViewState) {
            
        case .justMessage:
            containerView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 46, left: 24, bottom: 0, right: 24))
            
            imageView.anchor(leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0), size: CGSize(width: 20, height: 20))
            imageView.centerYToSuperview()
            
            messageLabel.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
        case .titleAndButtons:
            containerView.centerInSuperview()
            containerView.constrainWidth(212)
            
            titleLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8))
            titleLabel.constrainHeight(20)
            
            messageLabel.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            
            buttonsStackView.anchor(top: messageLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        case .justButtons:
            containerView.centerInSuperview()
            containerView.constrainWidth(212)
            
            buttonsStackView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            
        case .staticInfo:
            containerView.centerInSuperview()
            
            imageView.anchor(top: containerView.topAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), size: CGSize(width: 33, height: 33))
            imageView.centerXToSuperview()
            
            descriptionLabel.anchor(top: imageView.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 16, bottom: 12, right: 16))
        }
    }
}

// MARK: - Dragging animation
extension AlertView {
    
    func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alertViewTapped))
        containerView.addGestureRecognizer(panGesture)
        addGestureRecognizer(tapGesture)
    }
    
    @objc func alertViewTapped() {
        UIView.animate(withDuration: 1, delay: 0) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: -200)
            self.containerView.alpha = 0
        } completion: { status in
            self.delegate?.alertView(self, needDismiss: true)
        }
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startPosition = containerView.center.y
        } else if sender.state == .ended {
            endPosition = containerView.center.y
            
            guard let startPosition = startPosition,
                  let endPosition = endPosition
            else {
                return
            }
            
            if endPosition-startPosition < -30.0 {
                UIView.animate(withDuration: 1, delay: 0) {
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: -200)
                    self.containerView.alpha = 0
                    self.backgroundColor = .clear
                } completion: { status in
                    self.delegate?.alertView(self, needDismiss: true)
                }
            } else {
                UIView.animate(withDuration: 1, delay: 0) {
                    self.containerView.center.y = 60 + (self.containerView.frame.height) / 2
                }
            }
        }
        
        let translation = sender.translation(in: self.superview)
        containerView.center = CGPoint(x: containerView.center.x,
                                       y: containerView.center.y  + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.superview)
        
    }
}
