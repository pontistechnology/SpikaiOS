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
    }
    
    func setupBindings() {
        currentChatView.messageInputView.delegate = self
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
    }
}

extension CurrentChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int) {
        print("send in ccVC with ID")
        
        viewModel.testMessages.append(MessageTest(messageType: .text, textOfMessage: message, replyMessageId: id, senderName: "cova", isMyMessage: Bool.random()))
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
        currentChatView.messagesTableView.reloadData()
        currentChatView.messagesTableView.scrollToRow(at: IndexPath(row: viewModel.testMessages.count - 1, section: 0), at: .none, animated: true)
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.testMessages.append(MessageTest(messageType: .text, textOfMessage: message, replyMessageId: nil, senderName: "cova", isMyMessage: Bool.random()))
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
        currentChatView.messagesTableView.reloadData()
        currentChatView.messagesTableView.scrollToRow(at: IndexPath(row: viewModel.testMessages.count - 1, section: 0), at: .none, animated: true)
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
            self.currentChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.testMessages[indexPath.row]), id: indexPath.row)
                completionHandler(true)
            }
        firstLeft.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [firstLeft])
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.testMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.testMessages[indexPath.row]
        switch message.messageType {
        case .text:
            switch message.isMyMessage {
            case true:
                if let replyId = message.replyMessageId {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message, replyMessageTest: viewModel.testMessages[replyId])
                    return cell ?? UITableViewCell()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message)
                    return cell ?? UITableViewCell()
                }
            case false:
                if let replyId = message.replyMessageId {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message, replyMessageTest: viewModel.testMessages[replyId])
                    return cell ?? UITableViewCell()
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue, for: indexPath) as? TextMessageTableViewCell
                    cell?.updateCell(message: message)
                    return cell ?? UITableViewCell()
                }
            }
            
        case .photo:
            let cell = tableView.dequeueReusableCell(withIdentifier: MediaMessageTableViewCell.reuseIdentifier, for: indexPath) as? MediaMessageTableViewCell
            return cell ?? UITableViewCell()
        case .video:
            return UITableViewCell()
        case .voice:
            return UITableViewCell()
        }
    }
}
