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
    func messageInputView(didPressCameraButton messageVeiw: MessageInputView)
    func messageInputView(didPressMicrophoneButton messageVeiw: MessageInputView)
    func messageInputView(didPressLibraryButton messageVeiw: MessageInputView)
    func messageInputView(didPressFilesButton messageVeiw: MessageInputView)
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView)
}

class MessageInputView: UIView, BaseView {
    
    private let topLine = UIView()
    private let plusButton = UIButton()
    private let closeButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let messageTextView = UITextView()
    private let placeholderLabel = CustomLabel(text: "Type here...", textSize: 14, textColor: .textTertiary, fontName: .MontserratMedium)
    private let additionalOptionsView = AdditionalOptionsView()
    let selectedFilesView = SelectedFilesView()
    
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
        addSubview(topLine)
        addSubview(plusButton)
        addSubview(closeButton)
        addSubview(messageTextView)
        addSubview(microphoneButton)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(sendButton)
        messageTextView.addSubview(placeholderLabel)
    }
    
    func styleSubviews() {
        topLine.backgroundColor = .navigation
        
        messageTextView.textContainerInset.left = 10
        messageTextView.textContainerInset.right = 36
        messageTextView.layer.cornerRadius = 10
        messageTextView.clipsToBounds = true
        messageTextView.layer.borderColor = UIColor.borderColor.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.customFont(name: .MontserratMedium)
        
        plusButton.setImage(UIImage(safeImage: .plus), for: .normal)
        sendButton.setImage(UIImage(safeImage: .send), for: .normal)
        emojiButton.setImage(UIImage(safeImage: .smile), for: .normal)
        closeButton.setImage(UIImage(safeImage: .close), for: .normal)
        cameraButton.setImage(UIImage(safeImage: .camera), for: .normal)
        microphoneButton.setImage(UIImage(safeImage: .microphone), for: .normal)
        
        self.closeButton.alpha = 0
        self.sendButton.alpha = 0
    }
    
    func positionSubviews() {
        
        topLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        topLine.constrainHeight(0.5)
        
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
        
        placeholderLabel.anchor(leading: messageTextView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        placeholderLabel.centerYToSuperview()
    }
    
    func setupBindings() {
        messageTextView.delegate = self
        
        plusButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            if self.additionalOptionsView.superview == nil {
                self.showAdditionalOptions()
            } else {
                self.hideAdditionalOptions()
            }
            
            if self.selectedFilesView.superview != nil {
                self.hideSelectedFiles()
            }
        }.store(in: &subscriptions)
        
        additionalOptionsView.libraryImageView.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.hideAdditionalOptions()
            self.delegate?.messageInputView(didPressLibraryButton: self)
        }.store(in: &subscriptions)
        
        additionalOptionsView.filesImageView.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.hideAdditionalOptions()
            self.delegate?.messageInputView(didPressFilesButton: self)
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
            self.delegate?.messageInputView(self, didPressSend: text)
        }.store(in: &subscriptions)
        
        microphoneButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressMicrophoneButton: self)
        }.store(in: &subscriptions)
        
        cameraButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.messageInputView(didPressCameraButton: self)
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
}

// MARK: - Additional options view

extension MessageInputView {
    func showAdditionalOptions() {
        if additionalOptionsView.superview == nil {
            addSubview(additionalOptionsView)
            
            additionalOptionsView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            additionalOptionsView.constrainHeight(152)
            heightConstraint.constant += 152
        }
    }
    
    func hideAdditionalOptions() {
        if additionalOptionsView.superview != nil {
            additionalOptionsView.removeFromSuperview()
            heightConstraint.constant -= 152            
        }
    }
}

// MARK: - Selected files view

extension MessageInputView {
    func showSelectedFiles(_ files: [SelectedFile]) {
        if selectedFilesView.superview == nil {
            addSubview(selectedFilesView)
            
            selectedFilesView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            selectedFilesView.constrainHeight(120)
            heightConstraint.constant += selectedFilesView.height            
        }
        selectedFilesView.showFiles(files)
    }
    
    func hideSelectedFiles() {
        if selectedFilesView.superview != nil {
            selectedFilesView.removeFromSuperview()
            heightConstraint.constant -= selectedFilesView.height
        }
    }
}

extension MessageInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count == 0 {
            self.animateMessageView(isEmpty: true)
            wasMessageTextViewEmpty = true
            placeholderLabel.isHidden = false
        } else if wasMessageTextViewEmpty {
            self.animateMessageView(isEmpty: false)
            wasMessageTextViewEmpty = false
            placeholderLabel.isHidden = true
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
        
        heightConstraint.constant = heightOfTextView + 24
        + ((selectedFilesView.superview != nil) ? selectedFilesView.height : 0.0)
        
        messageTextViewHeightConstraint.constant = heightOfTextView
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
