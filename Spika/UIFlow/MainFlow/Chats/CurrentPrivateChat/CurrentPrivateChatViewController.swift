//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import SwiftUI

class CurrentPrivateChatViewController: BaseViewController {
    
    private let currentPrivateChatView = CurrentPrivateChatView()
    var viewModel: CurrentPrivateChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentPrivateChatView)
        setupBindings()
        checkRoom()
    }
    
    func setupBindings() {
        currentPrivateChatView.messageInputView.delegate = self
        currentPrivateChatView.messagesTableView.delegate = self
        currentPrivateChatView.messagesTableView.dataSource = self
        
        sink(networkRequestState: viewModel.networkRequestState)
        
        viewModel.messagesSubject.receive(on: DispatchQueue.main).sink { messages in
            self.currentPrivateChatView.messagesTableView.reloadData()
            self.currentPrivateChatView.messagesTableView.scrollToRow(at: IndexPath(row: self.viewModel.messagesSubject.value.count - 1, section: 0), at: .bottom, animated: true)
        }.store(in: &subscriptions)
    }
    
    func checkRoom() {
        viewModel.checkRoom()
    }
}

extension CurrentPrivateChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int) {
        print("send in ccVC with ID, this id is from array not message Id")
        
        viewModel.sendMessage(text: message)
        
        currentPrivateChatView.messageInputView.clearTextField()
        currentPrivateChatView.messageInputView.hideReplyView()
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.sendMessage(text: message)
        
        currentPrivateChatView.messageInputView.clearTextField()
        currentPrivateChatView.messageInputView.hideReplyView()
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

extension CurrentPrivateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let firstLeft = UIContextualAction(style: .normal, title: "Reply") { (action, view, completionHandler) in
    //            self.currentPrivateChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.messagesSubject.value[indexPath.row]), id: indexPath.row)
    //                completionHandler(true)
    //            }
    //        firstLeft.backgroundColor = .systemBlue
    //        return UISwipeActionsConfiguration(actions: [firstLeft])
    //    }
}

extension CurrentPrivateChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messagesSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUserId = viewModel.repository.getMyUserId()
        let message = viewModel.messagesSubject.value[indexPath.row]
        
        switch message.type {
        case "text":
            let identifier = (message.fromUserId == myUserId)
            ? TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue
            : TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
            cell?.updateCell(message: message)
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
}
    
    
    
    
    
    
    
    
    
    //        Commented because there is no replyId on backend for now
    //        switch message.messageType {
    //        case .text:
    //            break
    
    //
    //            switch message.isMyMessage {
    //            case true:
    //                if let replyId = message.replyMessageId {
    //                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
    //                    cell?.updateCell(message: message, replyMessageTest: viewModel.messagesSubject.value[replyId])
    //                    return cell ?? UITableViewCell()
    //                } else {
    //                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue, for: indexPath) as? TextMessageTableViewCell
    //                    cell?.updateCell(message: message)
    //                    return cell ?? UITableViewCell()
    //                }
    //            case false:
    //                if let replyId = message.replyMessageId {
    //                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendTextAndReply.rawValue, for: indexPath) as? TextMessageTableViewCell
    //                    cell?.updateCell(message: message, replyMessageTest: viewModel.messagesSubject.value[replyId])
    //                    return cell ?? UITableViewCell()
    //                } else {
    //                    let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue, for: indexPath) as? TextMessageTableViewCell
    //                    cell?.updateCell(message: message)
    //                    return cell ?? UITableViewCell()
    //                }
    //            }
    
    //        case .photo:
    //            return UITableViewCell()
    //        case .video:
    //            return UITableViewCell()
    //        case .voice:
    //            return UITableViewCell()
    //        }
    //    }
