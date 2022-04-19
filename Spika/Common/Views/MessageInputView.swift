//
//  MessageInputView.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit
import Combine

protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String)
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int)
    func messageInputView(didPressCameraButton messageVeiw: MessageInputView)
    func messageInputView(didPressMicrophoneButton messageVeiw: MessageInputView)
    func messageInputView(didPressPlusButton messageVeiw: MessageInputView)
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView)
}

class MessageInputView: UIView, BaseView {
    
    private let plusButton = UIButton()
    private let closeButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let messageTextView = UITextView()
    private var replyView: ReplyMessageView?
    private var replyViewId: Int?
    private let closeReplyViewButton = UIButton()
    
    private var messageTextViewHeightConstraint = NSLayoutConstraint()
    private var messageTextViewTrailingConstraint = NSLayoutConstraint()
    private var heightConstraint = NSLayoutConstraint()
    
    weak var delegate: MessageInputViewDelegate?
    private var subscriptions = Set<AnyCancellable>()
    private var wasMessageTextViewEmpty = true
    
    
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
        messageTextView.textContainerInset.right = 36
        messageTextView.layer.cornerRadius = 10
        messageTextView.clipsToBounds = true
        messageTextView.customFont(name: .MontserratMedium)
        
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        emojiButton.setImage(UIImage(named: "smile"), for: .normal)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera"), for: .normal)
        microphoneButton.setImage(UIImage(named: "microphone"), for: .normal)
        closeReplyViewButton.setImage(UIImage(named: "close"), for: .normal)
        
        self.closeButton.alpha = 0
        self.sendButton.alpha = 0
    }
    
    func positionSubviews() {
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 56)
        heightConstraint.isActive = true
        
        plusButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        closeButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        sendButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 56, height: 56))
        
        microphoneButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 20), size: CGSize(width: 20, height: 20))
        
        cameraButton.anchor(bottom: microphoneButton.bottomAnchor ,trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        
        emojiButton.anchor(bottom: messageTextView.bottomAnchor, trailing: messageTextView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 13), size: CGSize(width: 20, height: 20))
        
        messageTextView.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 56, bottom: 12, right: 0))
        messageTextViewHeightConstraint = messageTextView.heightAnchor.constraint(equalToConstant: 32)
        messageTextViewTrailingConstraint = messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -95)
        messageTextViewHeightConstraint.isActive = true
        messageTextViewTrailingConstraint.isActive = true
    }
    
    func setupBindings() {
        messageTextView.delegate = self
        
        plusButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressPlusButton: self)
        }.store(in: &subscriptions)
        
        closeButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.messageTextView.text = ""
            self.textViewDidChange(self.messageTextView)
            self.messageTextView.resignFirstResponder()
        }.store(in: &subscriptions)
        
        emojiButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressEmojiButton: self)
        }.store(in: &subscriptions)

        sendButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            let text = self.messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            if let replyViewId = self.replyViewId {
                self.delegate?.messageInputView(self, didPressSend: text, id: replyViewId)
            } else {
                self.delegate?.messageInputView(self, didPressSend: text)
            }
        }.store(in: &subscriptions)
        
        microphoneButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressMicrophoneButton: self)
        }.store(in: &subscriptions)
        
        cameraButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressCameraButton: self)
        }.store(in: &subscriptions)
        
        closeReplyViewButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.hideReplyView()
        }.store(in: &subscriptions)
    }
    
    func clearTextField() {
        messageTextView.text = ""
        textViewDidChange(self.messageTextView)
    }
    
    func animateMessageView(isEmpty: Bool) {
        self.messageTextViewTrailingConstraint.constant = isEmpty ? -95 : -60
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.plusButton.alpha = isEmpty ? 1 : 0
                self.closeButton.alpha = isEmpty ? 0 : 1
                self.sendButton.alpha = isEmpty ? 0 : 1
                self.cameraButton.alpha = isEmpty ? 1 : 0
                self.microphoneButton.alpha = isEmpty ? 1 : 0
                
                self.layoutIfNeeded()
            }
        }
    }
    
    func showReplyView(view: ReplyMessageView, id: Int) {
        if replyView == nil && replyViewId == nil {
            replyView = view
            replyViewId = id
            heightConstraint.constant += 60
            
            addSubview(replyView!)
            addSubview(closeReplyViewButton)
            replyView?.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 0))
            
            closeReplyViewButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 15), size: CGSize(width: 24, height: 24))
        } else {
            hideReplyView()
            showReplyView(view: view, id: id)
        }
    }
    
    func hideReplyView() {
        if replyView != nil && replyViewId != nil {
            replyView?.removeFromSuperview()
            closeReplyViewButton.removeFromSuperview()
            replyView = nil
            replyViewId = nil
            heightConstraint.constant -= 60
        }
    }
}

extension MessageInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count == 0 {
            self.animateMessageView(isEmpty: true)
            wasMessageTextViewEmpty = true
        } else if wasMessageTextViewEmpty {
            self.animateMessageView(isEmpty: false)
            wasMessageTextViewEmpty = false
        }
        
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
        
        heightConstraint.constant = heightOfTextView + 24 + (replyView != nil ? 60 : 0)
        
        messageTextViewHeightConstraint.constant = heightOfTextView
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
