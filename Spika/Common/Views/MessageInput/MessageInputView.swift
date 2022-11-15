//
//  MessageInputView.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit
import Combine

enum MessageInputViewState {
    case send(message: String)
    case camera
    case microphone
    case emoji
    case files
    case library
}

class MessageInputView: UIView, BaseView {
    
    private let dividerLine = UIView()
    private let plusButton = UIButton()
    private let closeButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let messageTextView = ExpandableTextView()
    private let additionalOptionsView = AdditionalOptionsView()
    let selectedFilesView = SelectedFilesView()
    
    private var messageTextViewTrailingConstraint = NSLayoutConstraint()
    
    let inputViewTapPublisher = PassthroughSubject<MessageInputViewState, Never>()
    
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
        addSubview(dividerLine)
        addSubview(plusButton)
        addSubview(closeButton)
        addSubview(messageTextView)
        addSubview(microphoneButton)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(sendButton)
    }
    
    func styleSubviews() {
        dividerLine.backgroundColor = .navigation
        
        plusButton.setImage(UIImage(safeImage: .plus), for: .normal)
        sendButton.setImage(UIImage(safeImage: .send), for: .normal)
        emojiButton.setImage(UIImage(safeImage: .smile), for: .normal)
        closeButton.setImage(UIImage(safeImage: .close), for: .normal)
        cameraButton.setImage(UIImage(safeImage: .camera), for: .normal)
        microphoneButton.setImage(UIImage(safeImage: .microphone), for: .normal)
        
        closeButton.alpha = 0
        sendButton.alpha = 0
    }
    
    func positionSubviews() {
        
        dividerLine.anchor(leading: leadingAnchor, bottom: messageTextView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        dividerLine.constrainHeight(0.5)
        
        plusButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        closeButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        sendButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 56, height: 56))
        
        microphoneButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 20), size: CGSize(width: 20, height: 20))
        
        cameraButton.anchor(bottom: microphoneButton.bottomAnchor ,trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        
        emojiButton.anchor(bottom: messageTextView.bottomAnchor, trailing: messageTextView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 13), size: CGSize(width: 20, height: 20))
        
        messageTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 12, left: 56, bottom: 12, right: 0))
        messageTextViewTrailingConstraint = messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -95)
        messageTextViewTrailingConstraint.isActive = true
    }
}

// MARK: - Bindings

extension MessageInputView {
    
    func setupBindings() {
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
        
        additionalOptionsView.publisher.sink { [weak self] state in
            self?.handleAdditionalOptions(state)
        }.store(in: &subscriptions)
        
        closeButton.tap().sink { [weak self] _ in
            self?.messageTextView.clearTextField(closeKeyboard: true)
        }.store(in: &subscriptions)
        
        emojiButton.tap().sink { [weak self] _ in
            self?.inputViewTapPublisher.send(.emoji)
        }.store(in: &subscriptions)

        sendButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            let text = self.messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            self.inputViewTapPublisher.send(.send(message: text))
            self.messageTextView.clearTextField()
        }.store(in: &subscriptions)
        
        microphoneButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.inputViewTapPublisher.send(.microphone)
        }.store(in: &subscriptions)
        
        cameraButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.inputViewTapPublisher.send(.camera)
        }.store(in: &subscriptions)
        
        messageTextView.textViewIsEmptyPublisher.sink { [weak self] state in
            self?.animateMessageView(isEmpty: state)
        }.store(in: &subscriptions)
    }
}

// MARK: - Animations

private extension MessageInputView {
    func animateMessageView(isEmpty: Bool) {
        self.messageTextViewTrailingConstraint.constant = isEmpty ? -95 : -60
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.plusButton.alpha = isEmpty ? 1 : 0
                self?.closeButton.alpha = isEmpty ? 0 : 1
                self?.sendButton.alpha = isEmpty ? 0 : 1
                self?.cameraButton.alpha = isEmpty ? 1 : 0
                self?.microphoneButton.alpha = isEmpty ? 1 : 0
                
                self?.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Additional options view

extension MessageInputView {
    func handleAdditionalOptions(_ state: AdditionalOptionsViewState) {
        self.hideAdditionalOptions()
        
        switch state {
        case .files:
            inputViewTapPublisher.send(.files)
        case .library:
            inputViewTapPublisher.send(.library)
        case .location:
            break
        case .contact:
            break
        }
    }
    func showAdditionalOptions() {
        if additionalOptionsView.superview == nil {
            addSubview(additionalOptionsView)
            additionalOptionsView.anchor(leading: leadingAnchor, bottom: dividerLine.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    func hideAdditionalOptions() {
        if additionalOptionsView.superview != nil {
            additionalOptionsView.removeFromSuperview()
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
        }
        selectedFilesView.showFiles(files)
    }
    
    func hideSelectedFiles() {
        if selectedFilesView.superview != nil {
            selectedFilesView.removeFromSuperview()
        }
    }
}
