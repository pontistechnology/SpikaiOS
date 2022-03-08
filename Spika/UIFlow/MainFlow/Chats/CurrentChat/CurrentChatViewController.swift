//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import SwiftUI

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    var viewModel: CurrentChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentChatView)
        setupBindings()
        viewModel.checkRoom(forUserId: viewModel.user.id)
    }
    
    func setupBindings() {
        currentChatView.messageInputView.delegate = self
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
        
        sink(networkRequestState: viewModel.networkRequestState)
        
        viewModel.testMessagesSubject.receive(on: DispatchQueue.main).sink { messages in
            self.currentChatView.messagesTableView.reloadData()
            self.currentChatView.messagesTableView.scrollToRow(at: IndexPath(row: self.viewModel.testMessagesSubject.value.count - 1, section: 0), at: .bottom, animated: true)
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int) {
        print("send in ccVC with ID")
        
//        viewModel.addMessage(message: MessageTest(messageType: .text, textOfMessage: message, replyMessageId: id, senderName: "cova", isMyMessage: Bool.random()))
        
        viewModel.sendMessage(text: message)
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.sendMessage(text: message)
//        viewModel.addMessage(message: MessageTest(messageType: .text, textOfMessage: message, replyMessageId: nil, senderName: "cova", isMyMessage: Bool.random()))
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
    }
    
    func messageInputView(didPressCameraButton messageVeiw: MessageInputView) {
        print("camera in ccVC")
    }
    
    func messageInputView(didPressMicrophoneButton messageVeiw: MessageInputView) {
        print("mic in ccVC")
    }
    
    func messageInputView(didPressPlusButton messageVeiw: MessageInputView) {
        print("plus in ccVC")
    }
    
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView) {
        print("emoji in ccVC")
    }
}

extension CurrentChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstLeft = UIContextualAction(style: .normal, title: "Reply") { (action, view, completionHandler) in
            self.currentChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.testMessagesSubject.value[indexPath.row]), id: indexPath.row)
                completionHandler(true)
            }
        firstLeft.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [firstLeft])
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.testMessagesSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.testMessagesSubject.value[indexPath.row]
        switch message.messageType {
        case .text:
            switch message.isMyMessage {
            case true:
                if let replyId = message.replyMessageId {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message, replyMessageTest: viewModel.testMessagesSubject.value[replyId])
                    return cell ?? UITableViewCell()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message)
                    return cell ?? UITableViewCell()
                }
            case false:
                if let replyId = message.replyMessageId {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message, replyMessageTest: viewModel.testMessagesSubject.value[replyId])
                    return cell ?? UITableViewCell()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message)
                    return cell ?? UITableViewCell()
                }
            }
            
        case .photo:
            return UITableViewCell()
        case .video:
            return UITableViewCell()
        case .voice:
            return UITableViewCell()
        }
    }
}
