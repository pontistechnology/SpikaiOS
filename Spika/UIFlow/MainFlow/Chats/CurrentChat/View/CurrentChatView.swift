//
//  CurrentPrivateChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import UIKit

class CurrentChatView: UIView, BaseView {
    
    let messagesTableView = UITableView(frame: .zero, style: .grouped)
    let messageInputView = MessageInputView()
    let downArrowImageView = UIImageView(image: UIImage(safeImage: .downArrow))
    
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
        addSubview(downArrowImageView)
        addSubview(messageInputView)
    }
    
    func styleSubviews() {
        messagesTableView.separatorStyle  = .none
        messagesTableView.keyboardDismissMode = .interactive
        messagesTableView.rowHeight = UITableView.automaticDimension
        messagesTableView.estimatedRowHeight = 5
        messagesTableView.backgroundColor = .clear
        messagesTableView.showsHorizontalScrollIndicator = false
        
        downArrowImageView.isHidden = true
        
        backgroundColor = .primaryBackground
    }
    
    func positionSubviews() {        
        messagesTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: messageInputView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0))
        
        downArrowImageView.anchor(bottom: messagesTableView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0))
        downArrowImageView.centerXToSuperview()
    
        messageInputView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        messageInputViewBottomConstraint.isActive = true
    }
    
    func setupBindings() {
        let cells = [TextMessageTableViewCell.self,
                     ImageMessageTableViewCell.self,
                     FileMessageTableViewCell.self,
                     AudioMessageTableViewCell.self,
                     VideoMessageTableViewCell.self,
                     DeletedMessageTableViewCell.self]
        
        cells.forEach { cell in
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.me.reuseIdentifierPrefix + String(describing: cell))
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.friend.reuseIdentifierPrefix + String(describing: cell))
            messagesTableView.register(cell, forCellReuseIdentifier: MessageSender.group.reuseIdentifierPrefix + String(describing: cell))
        }
        
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
    
    func hideScrollToBottomButton(should: Bool) {
        downArrowImageView.isHidden = should
    }
}


