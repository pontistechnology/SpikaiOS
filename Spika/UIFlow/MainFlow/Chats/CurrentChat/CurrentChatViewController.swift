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
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String?) {
        print("send in ccVC")
        guard let message = message else {
            return
        }
        viewModel.messages.append(message)
        currentChatView.messageInputView.clearTextField()
        currentChatView.messagesTableView.reloadData()
        currentChatView.messagesTableView.scrollToRow(at: IndexPath(row: viewModel.messages.count - 1, section: 0), at: .none, animated: true)
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
        let messageSize = viewModel.messages[indexPath.row].idealSizeForMessage(font: font, maximumWidth: 256)
        return messageSize.height + 40
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier, for: indexPath) as? MessageTableViewCell
        
        cell?.updateCell(text: viewModel.messages[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
}
