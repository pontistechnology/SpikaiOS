//
//  InputTextAndControlsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.12.2022..
//

import UIKit
import Combine

class InputTextAndControlsView: UIStackView {
    private let plusButton = CustomButton(assetName: .plus)
    private let sendButton = CustomButton(assetName: .send)
    private let cameraButton = CustomButton(assetName: .camera)
    private let microphoneButton = CustomButton(assetName: .microphone)
//    private let emojiButton = CustomButton(assetName: .smile)
    private let closeEditModeButton = CustomButton(assetName: .close)
    private let saveButton = CustomButton(text: "Save", textSize: 16, textColor: .primaryColor, fontName: .MontserratBold)
    private let editingModeLabel = CustomLabel(text: "Editing mode", textSize: 10, textColor: .textPrimary)
    private let messageTextView = ExpandableTextView()
    
    let keyboardAccessoryView = KeyboardObserverAccessoryView()
    
    private var subscriptions = Set<AnyCancellable>()
    let publisher: PassthroughSubject<MessageInputViewButtonAction, Never>
    
    init(publisher: PassthroughSubject<MessageInputViewButtonAction, Never>) {
        self.publisher = publisher
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension InputTextAndControlsView: BaseView {
    func addSubviews() {
        // order matters
        addArrangedSubview(plusButton)
        addArrangedSubview(closeEditModeButton)
        addArrangedSubview(messageTextView)
//        addArrangedSubview(emojiButton)
        addArrangedSubview(microphoneButton)
        addArrangedSubview(cameraButton)
        addArrangedSubview(saveButton)
        addArrangedSubview(sendButton)
        
        addSubview(editingModeLabel)
    }
    
    func styleSubviews() {
        sendButton.hide()
        closeEditModeButton.hide()
        saveButton.hide()
        editingModeLabel.hide()
    }
    
    func positionSubviews() {
        alignment = .center
        spacing = 10
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)
        isLayoutMarginsRelativeArrangement = true
        
        [plusButton, closeEditModeButton, microphoneButton, cameraButton, sendButton].forEach {
            $0.constrainWidth(48)
            $0.heightAnchor.constraint(equalTo: messageTextView.heightAnchor).isActive = true
        }
        
        setCustomSpacing(0, after: messageTextView)
        setCustomSpacing(0, after: microphoneButton)
        
        editingModeLabel.centerXToSuperview()
        editingModeLabel.anchor(top: messageTextView.bottomAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
    }
}

// MARK: - Animations

extension InputTextAndControlsView {
    func animateMessageView(to state: MessageInputViewState) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3) { [weak self] in
                .empty == state ? self?.cameraButton.unhide() : self?.cameraButton.hide()
                
                (.empty == state) ? self?.microphoneButton.unhide() : self?.microphoneButton.hide()
                
                (.writing == state) ? self?.sendButton.unhide() : self?.sendButton.hide()
                
                if case .editing(let string) = state {
                    self?.plusButton.hide()
                    self?.saveButton.unhide()
                    self?.editingModeLabel.unhide()
                    self?.messageTextView.setText(string)
                    self?.closeEditModeButton.unhide()
                } else {
                    self?.plusButton.unhide()
                    self?.saveButton.hide()
                    self?.editingModeLabel.hide()
                    self?.closeEditModeButton.hide()
                }
                
                self?.layoutIfNeeded()
            }
        }
    }
    
    func setupBindings() {
        messageTextView.inputAccessoryView = keyboardAccessoryView
        
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

//        emojiButton.tap().sink { [weak self] _ in
//            self?.publisher.send(.emoji)
//        }.store(in: &subscriptions)
        
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
