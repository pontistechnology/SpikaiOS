//
//  InputTextAndControlsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.12.2022..
//

import UIKit
import Combine

class InputTextAndControlsView: UIView {
    private let plusButton = UIButton()
    private let sendButton = UIButton()
    private let cameraButton = UIButton()
    private let microphoneButton = UIButton()
    private let emojiButton = UIButton()
    private let closeButton = UIButton()
    private let saveButton = UIButton()
    private let cancelEditingLabel = CustomLabel(text: "Cancel editing")
    private let messageTextView = ExpandableTextView()
    private var messageTextViewTrailingConstraint = NSLayoutConstraint()
    
    private var subscriptions = Set<AnyCancellable>()
    let publisher: PassthroughSubject<MessageInputViewButtonAction, Never>
    
    init(publisher: PassthroughSubject<MessageInputViewButtonAction, Never>) {
        self.publisher = publisher
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension InputTextAndControlsView: BaseView {
    func addSubviews() {
        addSubview(plusButton)
        addSubview(messageTextView)
        addSubview(microphoneButton)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(saveButton)
        addSubview(sendButton)
        addSubview(closeButton)
        addSubview(cancelEditingLabel)
    }
    
    func styleSubviews() {
        closeButton.setImage(UIImage(safeImage: .close), for: .normal)
        plusButton.setImage(UIImage(safeImage: .plus), for: .normal)
        sendButton.setImage(UIImage(safeImage: .send), for: .normal)
        emojiButton.setImage(UIImage(safeImage: .smile), for: .normal)
        cameraButton.setImage(UIImage(safeImage: .camera), for: .normal)
        microphoneButton.setImage(UIImage(safeImage: .microphone), for: .normal)
        saveButton.setTitle("Save", for: .normal)
        sendButton.alpha = 0
        closeButton.alpha = 0
        saveButton.alpha = 0
        cancelEditingLabel.alpha = 0
    }
    
    func positionSubviews() {
        messageTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 12, left: 56, bottom: 12, right: 0))
        messageTextViewTrailingConstraint = messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -95)
        messageTextViewTrailingConstraint.isActive = true
        
        cancelEditingLabel.centerXToSuperview()
        cancelEditingLabel.anchor(top: messageTextView.bottomAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        
        plusButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 0), size: CGSize(width: 24, height: 24))
        
        closeButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        sendButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 56, height: 56))
        
        microphoneButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 20), size: CGSize(width: 20, height: 20))
        
        cameraButton.anchor(bottom: microphoneButton.bottomAnchor ,trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        
        emojiButton.anchor(bottom: messageTextView.bottomAnchor, trailing: messageTextView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 13), size: CGSize(width: 20, height: 20))
        
        saveButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 56, height: 56))
    }
    
    func setText(_ text: String) {
        messageTextView.setText(text)
        saveButton.alpha = 1
        sendButton.alpha = 0
        cancelEditingLabel.alpha = 1
        cancelEditingLabel.text = "Edit mode"
    }
}

// MARK: - Animations

extension InputTextAndControlsView {
    func animateMessageView(to state: MessageInputViewState) {
        messageTextViewTrailingConstraint.constant =
            .empty == state ? -95 : -60
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.plusButton.alpha = .empty == state ? 1 : 0
                self?.closeButton.alpha = .empty == state ? 0 : 1
                self?.sendButton.alpha = .writing == state ? 1 : 0
                self?.cameraButton.alpha = .empty == state ? 1 : 0
                self?.microphoneButton.alpha = .empty == state ? 1 : 0
                
                if case .editing(let string) = state {
                    self?.saveButton.alpha = 1
                    self?.cancelEditingLabel.alpha = 1
                    self?.messageTextView.setText(string)
                } else {
                    self?.saveButton.alpha = 0
                    self?.cancelEditingLabel.alpha = 0
                }
                
                self?.layoutIfNeeded()
            }
        }
    }
    
    func setupBindings() {
        messageTextView.textViewIsEmptyPublisher.sink { [weak self] state in
            if state {
                self?.publisher.send(.everythisErased)
            }
        }.store(in: &subscriptions)
        
        plusButton.tap().sink { [weak self] _ in
            print("PLUS BUTTON")
            self?.publisher.send(.plus)
        }.store(in: &subscriptions)
        
        closeButton.tap().sink { [weak self] _ in
            self?.messageTextView.clearTextField(closeKeyboard: true)
//            self?.publisher.send() edit
        }.store(in: &subscriptions)

        emojiButton.tap().sink { [weak self] _ in
            self?.publisher.send(.emoji)
        }.store(in: &subscriptions)
        
        saveButton.tap().sink { [weak self] _ in
            guard let self else { return }
            let text = self.messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            self.publisher.send(.save(input: text))
            self.messageTextView.clearTextField()
        }.store(in: &subscriptions)

        sendButton.tap().sink { [weak self] _ in
            guard let self else { return }
            let text = self.messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            self.publisher.send(.send(message: text))
            self.messageTextView.clearTextField()
        }.store(in: &subscriptions)

        microphoneButton.tap().sink { [weak self] _ in
            guard let self else { return }
            self.publisher.send(.microphone)
        }.store(in: &subscriptions)

        cameraButton.tap().sink { [weak self] _ in
            guard let self else { return }
            self.publisher.send(.camera)
        }.store(in: &subscriptions)
        
        cancelEditingLabel.tap().sink { [weak self] _  in
            self?.publisher.send(.cancelEditing)
        }.store(in: &subscriptions)
    }
}
