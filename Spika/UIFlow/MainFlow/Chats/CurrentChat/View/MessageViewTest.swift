//
//  MessageViewTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit
import Combine

protocol MessageViewDelegate: AnyObject {
    func messageSenderView(_ messageSenderVeiw: MessageSenderView, didPressSend message: String?)
    func messageSenderView(didPressCameraButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressMicrophoneButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressPlusButton messageSenderVeiw: MessageSenderView)
    func messageSenderView(didPressEmojiButton messageSenderVeiw: MessageSenderView)
}

class MessageViewTest: UIView, BaseView {
    
    private let plusButton = UIButton()
    private let closeButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let messageTextView = UITextView()
    
    private var messageTextViewHeightConstraint = NSLayoutConstraint()
    private var heightConstraint = NSLayoutConstraint()
    
    private var rightConstraint = NSLayoutConstraint()
    weak var delegate: MessageViewDelegate?
    private var subscriptions = Set<AnyCancellable>()
    
    
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
        addSubview(messageTextView)
        addSubview(microphoneButton)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(sendButton)
    }
    
    func styleSubviews() {
        backgroundColor = .gray
        
        messageTextView.textContainerInset.left = 10
        messageTextView.textContainerInset.right = 50
        messageTextView.layer.cornerRadius = 10
        messageTextView.clipsToBounds = true
        
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        emojiButton.setImage(UIImage(named: "smile"), for: .normal)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        microphoneButton.setImage(UIImage(named: "microphone"), for: .normal)
    }
    
    func positionSubviews() {
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 56)
        heightConstraint.isActive = true
        
        plusButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        closeButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        sendButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 20), size: CGSize(width: 28, height: 28))
        
        microphoneButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 20), size: CGSize(width: 20, height: 20))
        
        cameraButton.anchor(bottom: microphoneButton.bottomAnchor ,trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        
        messageTextView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 56, bottom: 12, right: 95))
        messageTextViewHeightConstraint = messageTextView.heightAnchor.constraint(equalToConstant: 32)
        messageTextViewHeightConstraint.isActive = true
    }
    
    func setupBindings() {
        messageTextView.delegate = self
        
    }
    
    
}

extension MessageViewTest: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        var heightOfTextView: CGFloat = 32
        
        let numberOfLines = textView.numberOfLines()
        
        switch numberOfLines {
        case 0:
            heightOfTextView = 32
        case 1...5:
            heightOfTextView = 32 + (textView.font?.lineHeight ?? 0) * CGFloat(numberOfLines - 1)
        default:
            heightOfTextView = 32 + 5 * (textView.font?.lineHeight ?? 0)
        }
        
        heightConstraint.constant = heightOfTextView + 24
        messageTextViewHeightConstraint.constant = heightOfTextView
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
