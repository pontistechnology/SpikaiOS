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
    case scrollToReply(IndexPath)
    case plus
}

class MessageInputView: UIStackView, BaseView {
    
    let inputViewTapPublisher = PassthroughSubject<MessageInputViewState, Never>()
    private var subscriptions = Set<AnyCancellable>()

    private let dividerLine = UIView()
    private lazy var inputTextAndControlsView = InputTextAndControlsView(publisher: inputViewTapPublisher)
    var replyView: MessageReplyView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
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
        dividerLine.backgroundColor = .navigation
    }
    
    func positionSubviews() {
        dividerLine.constrainHeight(0.5)
        dividerLine.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

// MARK: - Bindings

extension MessageInputView {
    func clean() {
        hideReplyView()
    }
}

extension MessageInputView {
    func showReplyView(senderName: String, message: Message, indexPath: IndexPath?) {
        hideReplyView()
        if replyView == nil {
            self.replyView = MessageReplyView(senderName: senderName, message: message,
                                              backgroundColor: .chatBackground,
                                              indexPath: indexPath, showCloseButton: true)
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
            self?.hideReplyView()
        }).store(in: &subscriptions)
        
        replyView?.containerView.tap().sink(receiveValue: { [weak self] _ in
            guard let indexPath = self?.replyView?.indexPath else { return }
            self?.inputViewTapPublisher.send(.scrollToReply(indexPath))
        }).store(in: &subscriptions)
    }
}
