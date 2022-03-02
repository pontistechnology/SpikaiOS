//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit

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
        
        viewModel.testMessages.append(MessageTest(messageType: .text, textOfMessage: message, replyMessageId: id, senderName: "cova"))
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
        currentChatView.messagesTableView.reloadData()
        currentChatView.messagesTableView.scrollToRow(at: IndexPath(row: viewModel.testMessages.count - 1, section: 0), at: .none, animated: true)
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.testMessages.append(MessageTest(messageType: .text, textOfMessage: message, replyMessageId: nil, senderName: "cova"))
        
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let font = UIFont(name: CustomFontName.MontserratMedium.rawValue, size: 14) else {
            return 0
        }
        let messageSize = viewModel.testMessages[indexPath.row].textOfMessage!.idealSizeForMessage(font: font, maximumWidth: 256)
        return messageSize.height + 40 + (viewModel.testMessages[indexPath.row].replyMessageId != nil ? ReplyMessageView.replyMessageViewHeight + 10 : 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell
        print("replyId is: ", cell?.replyId)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier, for: indexPath) as? MessageTableViewCell
        
        if let replyId = viewModel.testMessages[indexPath.row].replyMessageId {
            cell?.updateCell(message: viewModel.testMessages[indexPath.row], replyMessage: viewModel.testMessages[replyId])
            cell?.delegate = self
        } else {
            cell?.updateCell(message: viewModel.testMessages[indexPath.row])
        }
        return cell ?? UITableViewCell()
    }
}

extension CurrentChatViewController: MessageTableViewCellDelegate {
    func messageTableViewCell(didPressOnReplyView: Bool) {
        print("prinaj")
    }
}
