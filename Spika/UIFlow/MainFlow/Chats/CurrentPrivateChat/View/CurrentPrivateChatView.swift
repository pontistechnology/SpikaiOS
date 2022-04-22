//
//  CurrentPrivateChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import UIKit

class CurrentPrivateChatView: UIView, BaseView {
    
    let messagesTableView = UITableView()
    let messageInputView = MessageInputView()
    
    private var messageInputViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(messagesTableView)
        addSubview(messageInputView)
    }
    
    func styleSubviews() {
        messagesTableView.backgroundColor = .blue
//        messagesTableView.separatorStyle  = .none
        messagesTableView.keyboardDismissMode = .onDrag
        messagesTableView.rowHeight = UITableView.automaticDimension
        messagesTableView.estimatedRowHeight = 5
    }
    
    func positionSubviews() {        
        messagesTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: messageInputView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8))
        
        messageInputView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        messageInputViewBottomConstraint.isActive = true
    }
    
    func setupBindings() {
        messagesTableView.register(TextMessageTableViewCell.self, forCellReuseIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue)
        messagesTableView.register(TextMessageTableViewCell.self, forCellReuseIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myTextAndReply.rawValue)
        messagesTableView.register(TextMessageTableViewCell.self, forCellReuseIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue)
        messagesTableView.register(TextMessageTableViewCell.self, forCellReuseIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendTextAndReply.rawValue)
        
        
        messagesTableView.register(MediaMessageTableViewCell.self, forCellReuseIdentifier: MediaMessageTableViewCell.reuseIdentifier)
        messagesTableView.register(VoiceMessageTableViewCell.self, forCellReuseIdentifier: VoiceMessageTableViewCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            messageInputViewBottomConstraint.constant = -keyboardSize.height
            layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        messageInputViewBottomConstraint.constant = 0
        layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
}


