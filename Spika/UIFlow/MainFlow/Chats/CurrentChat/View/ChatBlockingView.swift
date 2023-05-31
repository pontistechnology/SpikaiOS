//
//  ChatBlockingView.swift
//  Spika
//
//  Created by Vedran Vugrin on 20.02.2023..
//

import UIKit
import Combine

enum ChatBlockingViewState {
    case newChat, userBlocked, notInChat, notUsed
}

enum ChatBlockingViewAction {
    case blockUser, unblockUser, ok
}

class ChatBlockingView: UIView, BaseView {
    
    private let verticalStackView = CustomStackView()
    private let label = CustomLabel(text: .getStringFor(.youBlockedTheContact), textSize: 16, textColor: .textPrimary, alignment: .center)
    private let horizontalStackView = CustomStackView(axis: .horizontal, distribution: .fillEqually, spacing: 18)
    private let blockUnblockButton = MainButton()
    private let okButton = MainButton()
    
    private var state: ChatBlockingViewState = .notInChat
    private var subscriptions = Set<AnyCancellable>()
    let chatBlockingUserAction = PassthroughSubject<ChatBlockingViewAction,Never>()
    
    init() {
        super.init(frame: CGRectZero)
        self.setupView()
        
        self.hide()
        self.blockUnblockButton
            .tap()
            .map { [unowned self] _ -> ChatBlockingViewAction in
                if case .newChat = self.state {
                    return .blockUser
                } else {
                    return .unblockUser
                }
            }
            .subscribe(self.chatBlockingUserAction)
            .store(in: &self.subscriptions)
        
        self.okButton
            .tap()
            .map { _ -> ChatBlockingViewAction in
                return .ok
            }
            .subscribe(self.chatBlockingUserAction)
            .store(in: &self.subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateState(state: ChatBlockingViewState) {
        self.state = state
        switch state {
        case .newChat:
            okButton.unhide()
            self.label.text = .getStringFor(.newContact)
            blockUnblockButton.unhide()
            blockUnblockButton.setTitle(.getStringFor(.block), for: .normal)
        case .notInChat:
            okButton.hide()
            self.label.text = .getStringFor(.youAreNoLongerMember)
            blockUnblockButton.hide()
            blockUnblockButton.setTitle(.getStringFor(.unblock), for: .normal)
        case .userBlocked:
            okButton.hide()
            self.label.text = .getStringFor(.youBlockedTheContact)
            blockUnblockButton.unhide()
            blockUnblockButton.setTitle(.getStringFor(.unblock), for: .normal)
        case .notUsed:
            break
        }
        
        if case .notUsed = state {
            self.hide()
        } else {
            self.unhide()
        }
    }
    //self.label.text = .getStringFor(.youAreNoLongerMember)
    func styleSubviews() {
//        self.hide()
        self.backgroundColor = .textTertiary
        self.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        blockUnblockButton.backgroundColor = .primaryBackground
        blockUnblockButton.setTitleColor(.textPrimary, for: .normal)
        
        okButton.backgroundColor = .primaryBackground
        okButton.setTitleColor(.textPrimary, for: .normal)
        okButton.setTitle(.getStringFor(.ok), for: .normal)
    }
    
    func positionSubviews() {
        self.verticalStackView.constraint(to: nil, with: UIEdgeInsets(top: 22, left: 22, bottom: -42, right: -22))
    }
    
    func addSubviews() {
        self.addSubview(self.verticalStackView)
        self.verticalStackView.addArrangedSubview(self.label)
        self.verticalStackView.addArrangedSubview(self.horizontalStackView)
        self.horizontalStackView.addArrangedSubview(self.blockUnblockButton)
        self.horizontalStackView.addArrangedSubview(self.okButton)
    }
    
}

