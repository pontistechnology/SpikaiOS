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
    private let closeEditModeButton = UIButton()
    private let saveButton = UIButton()
    private let editingModeLabel = CustomLabel(text: "Editing mode", textColor: .textPrimary)
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
        addSubview(closeEditModeButton)
        addSubview(editingModeLabel)
    }
    
    func styleSubviews() {
        closeEditModeButton.setImage(UIImage(safeImage: .close), for: .normal)
        plusButton.setImage(UIImage(safeImage: .plus), for: .normal)
        sendButton.setImage(UIImage(safeImage: .send), for: .normal)
        emojiButton.setImage(UIImage(safeImage: .smile), for: .normal)
        cameraButton.setImage(UIImage(safeImage: .camera), for: .normal)
        microphoneButton.setImage(UIImage(safeImage: .microphone), for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.primaryColor, for: .normal)
        saveButton.setTitleColor(.textSecondary, for: .disabled)
        sendButton.alpha = 0
        closeEditModeButton.alpha = 0
        saveButton.alpha = 0
        editingModeLabel.alpha = 0
    }
    
    func positionSubviews() {
        messageTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 12, left: 56, bottom: 12, right: 0))
        messageTextViewTrailingConstraint = messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -95)
        messageTextViewTrailingConstraint.isActive = true
        
        editingModeLabel.centerXToSuperview()
        editingModeLabel.anchor(top: messageTextView.bottomAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        
        plusButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 0), size: CGSize(width: 24, height: 24))
        
        closeEditModeButton.anchor(leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0), size: CGSize(width: 16, height: 16))
        
        sendButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 56, height: 56))
        
        microphoneButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 20), size: CGSize(width: 20, height: 20))
        
        cameraButton.anchor(bottom: microphoneButton.bottomAnchor ,trailing: microphoneButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), size: CGSize(width: 20, height: 20))
        
        emojiButton.anchor(bottom: messageTextView.bottomAnchor, trailing: messageTextView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 13), size: CGSize(width: 20, height: 20))
        
        saveButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4), size: CGSize(width: 56, height: 56))
    }
}

// MARK: - Animations

extension InputTextAndControlsView {
    func animateMessageView(to state: MessageInputViewState) {
        messageTextViewTrailingConstraint.constant =
            .empty == state ? -95 : -60
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.cameraButton.alpha = .empty == state ? 1 : 0
                self?.microphoneButton.alpha = .empty == state ? 1 : 0
                self?.sendButton.alpha = .writing == state ? 1 : 0
                
                if case .editing(let string) = state {
                    self?.plusButton.alpha = 0
                    self?.saveButton.alpha = 1
                    self?.editingModeLabel.alpha = 1
                    self?.messageTextView.setText(string)
                    self?.closeEditModeButton.alpha = 1
                } else {
                    self?.plusButton.alpha = 1
                    self?.saveButton.alpha = 0
                    self?.editingModeLabel.alpha = 0
                    self?.closeEditModeButton.alpha = 0
                }
                
                self?.layoutIfNeeded()
            }
        }
    }
    
    func setupBindings() {
        messageTextView.textViewIsEmptyPublisher.sink { [weak self] isEmpty in
            self?.publisher.send(.inputIsEmpty(isEmpty))
            self?.saveButton.isEnabled = !isEmpty
        }.store(in: &subscriptions)
        
        plusButton.tap().sink { [weak self] _ in
            print("PLUS BUTTON")
            self?.publisher.send(.plus)
        }.store(in: &subscriptions)
        
        closeEditModeButton.tap().sink { [weak self] _ in
            self?.messageTextView.clearTextField(closeKeyboard: true)
            self?.publisher.send(.cancelEditing)
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
    }
}
