//
//  MessageInputView.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import Foundation
import UIKit
import Combine

enum MessageInputViewButtonAction {
    case send(message: String)
    case camera
    case microphone
//    case emoji
    case scrollToReply
    case plus
    case save(input: String)
    case hideReply
    case cancelEditing
    case inputIsEmpty(Bool)
}

enum MessageInputViewState: Comparable {
    case empty
    case writing
    case editing(String)
}

class MessageInputView: UIStackView, BaseView {
    
    let inputViewTapPublisher = PassthroughSubject<MessageInputViewButtonAction, Never>()
    let currentStatePublisher = CurrentValueSubject<MessageInputViewState, Never>(.empty)
    private var subscriptions = Set<AnyCancellable>()
    
    lazy var inputTextAndControlsView = InputTextAndControlsView(publisher: inputViewTapPublisher)
    var replyView: MessageReplyView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addArrangedSubview(inputTextAndControlsView)
    }
    
    func styleSubviews() {
        axis = .vertical
        backgroundColor = .clear
    }
    
    func positionSubviews() {
    }
    
    func setupBindings() {
        currentStatePublisher.sink { [weak self] state in
            self?.inputTextAndControlsView.animateMessageView(to: state)
        }.store(in: &subscriptions)
        
        inputViewTapPublisher.sink { [weak self] state in
            switch state {
            case .inputIsEmpty(let isEmpty):
                if self?.currentStatePublisher.value == .writing && isEmpty {
                    self?.currentStatePublisher.send(.empty)
                }
                if self?.currentStatePublisher.value == .empty && !isEmpty {
                    self?.currentStatePublisher.send(.writing)
                }
            default:
                break
            }
        }.store(in: &subscriptions)
    }
}

// MARK: - Bindings

extension MessageInputView {
    func clean() {
        hideReplyView()
    }
}

extension MessageInputView {
    func showReplyView(senderName: String, message: Message) {
        hideReplyView()
        if replyView == nil {
            self.replyView = MessageReplyView(senderName: senderName, message: message,
                                              backgroundColor: .secondaryColor, showCloseButton: true)
            replyBindings()
            guard let replyView = replyView else { return }
            backgroundColor = .secondAdditionalColor
            insertArrangedSubview(replyView, at: 0)
        }
    }
    
    func hideReplyView() {
        replyView?.removeFromSuperview()
        replyView = nil
        backgroundColor = .clear
    }
    
    func replyBindings() {
        replyView?.closeButton.tap().sink(receiveValue: { [weak self] _ in
            self?.inputViewTapPublisher.send(.hideReply)
        }).store(in: &subscriptions)
        
        replyView?.containerView.tap().sink(receiveValue: { [weak self] _ in
            self?.inputViewTapPublisher.send(.scrollToReply)
        }).store(in: &subscriptions)
    }
}
