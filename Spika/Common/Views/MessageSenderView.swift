//
//  MessageSenderView.swift
//  Spika
//
//  Created by Marko on 25.10.2021..
//

import UIKit
import Combine

protocol MessageSenderDelegate: AnyObject {
    func messageSenderView(_ messageSenderVeiw: MessageSenderView, didPressSend message: String?)
    func messageSenderView(didPressCameraButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressMicrophoneButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressPlusButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressEmojiButton messageSenderVeiw: MessageSenderView)
}

class MessageSenderView: UIView, BaseView {
    
    private let plusButton = UIButton()
    private let closeButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let messageTextField = MessageTextField()
    
    private var rightConstraint = NSLayoutConstraint()
    weak var delegate: MessageSenderDelegate?
    private var subscriptions = Set<AnyCancellable>()
    private var textFieldValue: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(plusButton)
        addSubview(closeButton)
        addSubview(messageTextField)
        addSubview(microphoneButton)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(sendButton)
    }
    
    func styleSubviews() {
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        emojiButton.setImage(UIImage(named: "smile"), for: .normal)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        microphoneButton.setImage(UIImage(named: "microphone"), for: .normal)
        
        closeButton.isHidden = true
        sendButton.isHidden = true
    }
    
    func positionSubviews() {
        self.constrainHeight(60)
        
        plusButton.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), size: CGSize(width: 16, height: 16))
        plusButton.centerY(inView: self)
        
        closeButton.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), size: CGSize(width: 16, height: 16))
        closeButton.centerY(inView: self)
        
        sendButton.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), size: CGSize(width: 28, height: 28))
        sendButton.centerY(inView: self)
        
        microphoneButton.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        microphoneButton.centerY(inView: self)
        
        cameraButton.anchor(trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        cameraButton.centerY(inView: self)
        
        messageTextField.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 95))
        messageTextField.constrainHeight(35)
        messageTextField.centerY(inView: self)
        rightConstraint = messageTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -95)
        
        emojiButton.anchor(trailing: messageTextField.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 13), size: CGSize(width: 20, height: 20))
        emojiButton.centerY(inView: self)
        
        NSLayoutConstraint.activate([
           rightConstraint,
        ])
        
    }
    
    func setupBindings() {
        messageTextField.addTarget(self, action: #selector(MessageSenderView.textFieldDidChange(_:)), for: .editingChanged)
        
        closeButton.tap().sink { [weak self] _ in
            self?.clearTextField()
            self?.messageTextField.endEditing(true)
        }.store(in: &subscriptions)
        
        plusButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageSenderView(didPressPlusButton: self)
        }.store(in: &subscriptions)
        
        cameraButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageSenderView(didPressCameraButton: self)
        }.store(in: &subscriptions)
        
        microphoneButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageSenderView(didPressMicrophoneButton: self)
        }.store(in: &subscriptions)
        
        emojiButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageSenderView(didPressEmojiButton: self)
        }.store(in: &subscriptions)
        
        sendButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageSenderView(self, didPressSend: self.messageTextField.text)
            self.clearTextField()
        }.store(in: &subscriptions)
    }
    
    func setPlaceholder(_ placeholder: String) {
        self.messageTextField.placeholder = placeholder
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let newValue = textField.text {
            if newValue.isEmpty {
                self.animateMessageTextView(isTextFieldEmpty: true)
            } else {
                if textFieldValue.count == 0 {
                    self.animateMessageTextView(isTextFieldEmpty: false)
                }
            }
            textFieldValue = newValue
        } else {
            animateMessageTextView(isTextFieldEmpty: true)
        }
    }
    
    func clearTextField() {
        self.messageTextField.text = ""
        self.textFieldValue = ""
        self.animateMessageTextView(isTextFieldEmpty: true)
    }
    
    private func animateMessageTextView(isTextFieldEmpty: Bool) {
        setupOpacityOnButtons(isTextFieldEmpty: !isTextFieldEmpty)
        setVisibilityForButtons(visible: true)
        let options: UIView.AnimationOptions = isTextFieldEmpty ? [.curveEaseIn] : [.curveEaseOut]
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: options,
                       animations: {
            self.setupOpacityOnButtons(isTextFieldEmpty: isTextFieldEmpty)
            self.rightConstraint.constant = isTextFieldEmpty ? -95 : -60
            self.layoutIfNeeded()
        }) { isCompleted in
            if isCompleted {
                self.setupVisibilityOnButtons(isTextFieldEmpty: isTextFieldEmpty)
            }
        }
        
    }
    
    private func setupOpacityOnButtons(isTextFieldEmpty: Bool) {
        self.closeButton.alpha = isTextFieldEmpty ? 0 : 1
        self.sendButton.alpha = isTextFieldEmpty ? 0 : 1
        self.plusButton.alpha = isTextFieldEmpty ? 1 : 0
        self.cameraButton.alpha = isTextFieldEmpty ? 1 : 0
        self.microphoneButton.alpha = isTextFieldEmpty ? 1 : 0
    }
    
    private func setupVisibilityOnButtons(isTextFieldEmpty: Bool) {
        self.closeButton.isHidden = isTextFieldEmpty
        self.sendButton.isHidden = isTextFieldEmpty
        self.plusButton.isHidden = !isTextFieldEmpty
        self.cameraButton.isHidden = !isTextFieldEmpty
        self.microphoneButton.isHidden = !isTextFieldEmpty
    }
    
    private func setVisibilityForButtons(visible: Bool) {
        self.closeButton.isHidden = !visible
        self.sendButton.isHidden = !visible
        self.plusButton.isHidden = !visible
        self.cameraButton.isHidden = !visible
        self.microphoneButton.isHidden = !visible
    }
    
}

