//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import CoreData

class CurrentPrivateChatViewController: BaseViewController {
    
    private let currentPrivateChatView = CurrentPrivateChatView()
    var viewModel: CurrentPrivateChatViewModel!
    let friendInfoView = ChatNavigationBarView()
    var i = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check room first then prooceed if success
        checkRoom()
        setupView(currentPrivateChatView)
        setupBindings()
        setupNavigationItems()
        viewModel.setFetch()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        print("currentChatVC deinit")
    }
}

// MARK: Functions

extension CurrentPrivateChatViewController {
    func setupBindings() {
        currentPrivateChatView.messageInputView.delegate = self
        currentPrivateChatView.messagesTableView.delegate = self
        currentPrivateChatView.messagesTableView.dataSource = self
        viewModel.coreDataFetchedResults.delegate = self
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
    
    func checkRoom() {
        viewModel.checkRoom()
    }
}

// MARK: MessageInputView actions

extension CurrentPrivateChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int) {
        print("send in ccVC with ID, this id is from array not message Id")
        
        viewModel.trySendMessage(text: message)
        
        currentPrivateChatView.messageInputView.clearTextField()
        currentPrivateChatView.messageInputView.hideReplyView()
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.trySendMessage(text: message)

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

// MARK: UITableView

extension CurrentPrivateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        friendInfoView.changeStatus(to: viewModel.coreDataFetchedResults.controller.object(at: indexPath).bodyText ?? "no bodyText")
        i += 1
        navigationController?.navigationBar.backItem?.backButtonTitle = "\(i)"
    }
}

extension CurrentPrivateChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let messageEntities = viewModel.coreDataFetchedResults.controller.sections?[section] else {
            return 0
        }
        return messageEntities.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUserId = viewModel.repository.getMyUserId()
        
        let messageEntity = viewModel.coreDataFetchedResults.controller.object(at: indexPath)
        
        let identifier = (messageEntity.fromUserId == myUserId || messageEntity.fromUserId == -1)
                        ? TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue
                        : TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
        cell?.updateCell(messageEntity: messageEntity)
        return cell ?? UITableViewCell()
    }
}

// MARK: Navigation items setup

extension CurrentPrivateChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(named: "videoCall"), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(named: "phoneCall"), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true

        friendInfoView.change(avatarUrl: viewModel.friendUser.avatarUrl, name: viewModel.friendUser.displayName, lastSeen: "yesterday")
        let vtest = UIBarButtonItem(customView: friendInfoView)
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: swipe gestures on cells

extension CurrentPrivateChatViewController {
    //    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let firstLeft = UIContextualAction(style: .normal, title: "Reply") { (action, view, completionHandler) in
    //            self.currentPrivateChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.messagesSubject.value[indexPath.row]), id: indexPath.row)
    //                completionHandler(true)
    //            }
    //        firstLeft.backgroundColor = .systemBlue
    //        return UISwipeActionsConfiguration(actions: [firstLeft])
    //    }
}
    
// MARK: reply to message
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

extension CurrentPrivateChatViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentPrivateChatView.messagesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath!], with: .automatic)
            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            let cell = currentPrivateChatView.messagesTableView.cellForRow(at: indexPath!) as? TextMessageTableViewCell
            let a = viewModel.coreDataFetchedResults.controller.object(at: indexPath!)
            cell?.updateCell(messageEntity: a)
        @unknown default:
            fatalError("new versions of type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentPrivateChatView.messagesTableView.endUpdates()
        currentPrivateChatView.messagesTableView.scrollToBottom()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            currentPrivateChatView.messagesTableView.insertSections(indexSet, with: .automatic)
        case .delete:
            currentPrivateChatView.messagesTableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}
