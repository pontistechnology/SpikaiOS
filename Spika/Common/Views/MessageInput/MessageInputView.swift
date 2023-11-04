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

    private let dividerLine = UIView()
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
        addSubview(dividerLine)
        addArrangedSubview(inputTextAndControlsView)
    }
    
    func styleSubviews() {
        axis = .vertical
        dividerLine.backgroundColor = ._textSecondary
    }
    
    func positionSubviews() {
        dividerLine.constrainHeight(0.5)
        dividerLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
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
                                              backgroundColor: ._secondaryColor, showCloseButton: true)
            replyBindings()
            guard let replyView = replyView else { return }
            insertArrangedSubview(replyView, at: 0)
        }
    }
    
    func hideReplyView() {
        replyView?.removeFromSuperview()
        replyView = nil
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
