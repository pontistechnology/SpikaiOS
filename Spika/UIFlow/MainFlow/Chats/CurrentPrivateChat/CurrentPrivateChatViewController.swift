//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import CoreData
import PhotosUI

class CurrentPrivateChatViewController: BaseViewController {
    
    private let currentPrivateChatView = CurrentPrivateChatView()
    var viewModel: CurrentPrivateChatViewModel!
    let friendInfoView = ChatNavigationBarView()
    var i = 1
    var frc: NSFetchedResultsController<MessageEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentPrivateChatView)
        setupNavigationItems()
        setupBindings()
        checkRoom()
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
    func checkRoom() {
        viewModel.checkLocalRoom()
    }

    func setupBindings() {
        currentPrivateChatView.messageInputView.delegate = self
        currentPrivateChatView.messagesTableView.delegate = self
        currentPrivateChatView.messagesTableView.dataSource = self
        sink(networkRequestState: viewModel.networkRequestState)
        
        viewModel.roomPublisher.sink { completion in
            // TODO: pop vc?, presentAlert?
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                PopUpManager.shared.presentAlert(with: (title: "Error", message: error.localizedDescription), orientation: .horizontal, closures: [("Ok", {
                    self.viewModel.getAppCoordinator()?.popTopViewController()
                })])
            }
        } receiveValue: { [weak self] room in
            guard let self = self else { return }
            self.setFetch(room: room)
        }.store(in: &subscriptions)
        
        currentPrivateChatView.downArrowImageView.tap().sink { [weak self] _ in
            self?.currentPrivateChatView.messagesTableView.scrollToBottom()
        }.store(in: &subscriptions)
    }
}

// MARK: - NSFetchedResultsController

extension CurrentPrivateChatViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch(room: Room) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = MessageEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "room.id == %d", room.id)
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            do {
                try self.frc?.performFetch()
                self.currentPrivateChatView.messagesTableView.reloadData()
            } catch {
                fatalError("Failed to fetch entities: \(error)") // TODO: handle error
            }
        }
        
        viewModel.roomVisited(roomId: room.id)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentPrivateChatView.messagesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            currentPrivateChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else {
                return
            }
//            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
//            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath!], with: .left)
            
            currentPrivateChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            
//            let cell = currentPrivateChatView.messagesTableView.cellForRow(at: indexPath) as? TextMessageTableViewCell
//            let entity = frc?.object(at: indexPath)
//            let message = Message(messageEntity: entity!)
//            cell?.updateCell(message: message)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentPrivateChatView.messagesTableView.endUpdates()
        currentPrivateChatView.messagesTableView.scrollToBottom()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        print("snapshot begi: ", snapshot)
//        currentPrivateChatView.messagesTableView.reloadData()
//        currentPrivateChatView.messagesTableView.scrollToBottom()
//    }
}


// MARK: - MessageInputView actions

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
        presentLibraryPicker()
    }
    
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView) {
        print("emoji in ccVC")
    }
}

// MARK: - UITableView

extension CurrentPrivateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TextMessageTableViewCell else { return }
        (tableView.visibleCells as? [TextMessageTableViewCell])?.forEach{ $0.timeLabel.isHidden = true}
        cell.tapHandler()
        tableView.deselectRow(at: indexPath, animated: true)
        friendInfoView.changeStatus(to: "\(i)")
        i += 1
        navigationController?.navigationBar.backItem?.backButtonTitle = "\(i)"
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let totalSections = self.frc?.sections?.count,
              let totalRowsInLastSection = self.frc?.sections?[totalSections - 1].numberOfObjects,
              let isLastRowVisible = tableView.indexPathsForVisibleRows?.contains(IndexPath(row: totalRowsInLastSection - 1, section: totalSections - 1)) else {
            return
        }
        
        currentPrivateChatView.hideScrollToBottomButton(should: isLastRowVisible)

    }
    
    
}

extension CurrentPrivateChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUserId = viewModel.repository.getMyUserId()
        guard let entity = frc?.object(at: indexPath) else { return UITableViewCell()}
        
        for rec in entity.records! {
            print("rrec: ", (rec as! MessageRecordEntity).type)
        }
        
        let message = Message(messageEntity: entity)
        
        let identifier = (message.fromUserId == myUserId)
                        ? TextMessageTableViewCell.TextReuseIdentifier.myText.rawValue
                        : TextMessageTableViewCell.TextReuseIdentifier.friendText.rawValue
        
        
        print(identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
        
        cell?.updateCell(message: message)
        cell?.updateCellState(to: message.getMessageState(myUserId: myUserId))
        
        if message.type == "image" {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: ImageMessageTableViewCell.ImageReuseIdentifier.myImage.rawValue, for: indexPath) as? ImageMessageTableViewCell
            cell2?.updateCell(message: message)
            cell2?.updateCellState(to: message.getMessageState(myUserId: myUserId))
            return cell2 ?? UITableViewCell()
        }
        
        return cell ?? UITableViewCell()
    }
}

// MARK: - Navigation items setup

extension CurrentPrivateChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(named: "videoCall"), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(named: "phoneCall"), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true

        friendInfoView.change(avatarUrl: viewModel.friendUser.getAvatarUrl(), name: viewModel.friendUser.getDisplayName(), lastSeen: "yesterday")
        let vtest = UIBarButtonItem(customView: friendInfoView)
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentPrivateChatViewController {
//        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//            let firstLeft = UIContextualAction(style: .normal, title: "Reply") { (action, view, completionHandler) in
//                self.currentPrivateChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.messagesSubject.value[indexPath.row]), id: indexPath.row)
//                    completionHandler(true)
//                }
//            firstLeft.backgroundColor = .systemBlue
//            return UISwipeActionsConfiguration(actions: [firstLeft])
//        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRight = UIContextualAction(style: .normal, title: "Details") { (action, view, completionHandler) in
            if let messageEntity = self.frc?.object(at: indexPath),
               let records = Message(messageEntity: messageEntity).records {
                self.viewModel.presentMessageDetails(records: records)
                completionHandler(true)
            }
        }
        firstRight.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [firstRight])
    }
    
}

extension CurrentPrivateChatViewController: PHPickerViewControllerDelegate {
    
    func presentLibraryPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = .any(of: [.images, .livePhotos, .videos])
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 30
        //        configuration.selection = .ordered // iOS 15 required
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                    guard let data = data else { return }
                    print(data)
                    self.viewModel.sendImage(data: data)
                }
            }
        }
        
        print("PHPICKER: ", results)
    }
    
    
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
