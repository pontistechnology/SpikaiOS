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
    
    lazy var coreDataFetchedResults = CoreDataFetchedResults(ofType: MessageEntity.self, entityName: "MessageEntity", sortDescriptors: [], managedContext: CoreDataManager.shared.managedContext, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentPrivateChatView)
        setupBindings()
        setupNavigationItems()
        checkRoom()
        test()
    }
    
    func test() {
        let predicate = NSPredicate(format: "%K != %@", #keyPath(MessageEntity.bodyText), "miki")
        coreDataFetchedResults.controller.fetchRequest.predicate = predicate
        coreDataFetchedResults.performFetch()
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
        
        sink(networkRequestState: viewModel.networkRequestState)
        
//        viewModel.messagesSubject.receive(on: DispatchQueue.main).sink { [weak self] messages in
//            guard let self = self else { return }
//            self.currentPrivateChatView.messagesTableView.reloadData()
//            self.currentPrivateChatView.messagesTableView.scrollToRow(at: IndexPath(row: self.viewModel.messagesSubject.value.count - 1, section: 0), at: .bottom, animated: true)
//        }.store(in: &subscriptions)
        
//        viewModel.allMessagesSubject.receive(on: DispatchQueue.main).sink { [weak self] localMessages in
//            guard let self = self else { return }
//
//            self.currentPrivateChatView.messagesTableView.reloadData()
//            self.currentPrivateChatView.messagesTableView.scrollToRow(at: IndexPath(row: self.viewModel.allMessagesSubject.value.count - 1, section: 0), at: .bottom, animated: true)
//        }.store(in: &subscriptions)
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
        friendInfoView.changeStatus(to: viewModel.allMessagesSubject.value[indexPath.row].message.body.text)
        i += 1
        navigationController?.navigationBar.backItem?.backButtonTitle = "\(i)"
    }
}

extension CurrentPrivateChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        viewModel.allMessagesSubject.value.count
        
        guard let si = coreDataFetchedResults.controller.sections?[section] else {
            return 0
        }
        return si.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUserId = viewModel.repository.getMyUserId()
        let message = viewModel.allMessagesSubject.value[indexPath.row]
        
        let a = coreDataFetchedResults.controller.object(at: indexPath)
        
        let identifier = (a.fromUserId == myUserId || a.fromUserId == 999)
                        ? TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue
                        : TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
        cell?.updateCell(message: Message(text: a.bodyText ?? "fali"))
        return cell ?? UITableViewCell()
//        switch message.message.type {
//        case "text":
//            let identifier = (message.message.fromUserId == myUserId || message.message.fromUserId == 999)
//            ? TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue
//            : TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
//            cell?.updateCell(message: message.message)
//            cell?.updateCell(messageState: message.status)
//            return cell ?? UITableViewCell()
//        default:
//            return UITableViewCell()
//        }
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
            cell?.updateCell(message: Message(text: "UPDATE"))
        @unknown default:
            fatalError("new versions of type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentPrivateChatView.messagesTableView.endUpdates()
    }
}
