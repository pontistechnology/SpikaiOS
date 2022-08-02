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

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    var viewModel: CurrentChatViewModel!
    let friendInfoView = ChatNavigationBarView()
    var i = 1
    var frc: NSFetchedResultsController<MessageEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentChatView)
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

extension CurrentChatViewController {
    func checkRoom() {
        viewModel.checkLocalRoom()
    }

    func setupBindings() {
        currentChatView.messageInputView.delegate = self
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
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
        
        currentChatView.downArrowImageView.tap().sink { [weak self] _ in
            self?.currentChatView.messagesTableView.scrollToBottom()
        }.store(in: &subscriptions)
    }
}

// MARK: - NSFetchedResultsController

extension CurrentChatViewController: NSFetchedResultsControllerDelegate {
    
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
                self.currentChatView.messagesTableView.reloadData()
            } catch {
                fatalError("Failed to fetch entities: \(error)") // TODO: handle error
            }
        }
        
        viewModel.roomVisited(roomId: room.id)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            currentChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            currentChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            currentChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else {
                return
            }
//            currentChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
//            currentChatView.messagesTableView.insertRows(at: [newIndexPath!], with: .left)
            
            currentChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            
//            let cell = currentChatView.messagesTableView.cellForRow(at: indexPath) as? TextMessageTableViewCell
//            let entity = frc?.object(at: indexPath)
//            let message = Message(messageEntity: entity!)
//            cell?.updateCell(message: message)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.endUpdates()
        currentChatView.messagesTableView.scrollToBottom()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        print("snapshot begi: ", snapshot)
//        currentChatView.messagesTableView.reloadData()
//        currentChatView.messagesTableView.scrollToBottom()
//    }
}


// MARK: - MessageInputView actions

extension CurrentChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageView: MessageInputView, didPressSend message: String, id: Int) {
        print("send in ccVC with ID, this id is from array not message Id")
        
        viewModel.trySendMessage(text: message)
        
        currentChatView.messageInputView.clearTextField()
        currentChatView.messageInputView.hideReplyView()
    }
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.trySendMessage(text: message)

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
        presentLibraryPicker()
    }
    
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView) {
        print("emoji in ccVC")
    }
}

// MARK: - UITableView

extension CurrentChatViewController: UITableViewDelegate {
    
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
        
        currentChatView.hideScrollToBottomButton(should: isLastRowVisible)

    }
    
    
}

extension CurrentChatViewController: UITableViewDataSource {
    
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
        
        if message.type == "text" {
            var identifier = ""
            
            if myUserId == message.fromUserId! {
                identifier = TextMessageTableViewCell.myTextReuseIdentifier
            } else if viewModel.room?.type == "private" {
                identifier = TextMessageTableViewCell.friendTextReuseIdentifier
            } else {
                identifier = TextMessageTableViewCell.groupTextReuseIdentifier
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TextMessageTableViewCell
            
            cell?.updateCell(message: message)
            cell?.updateCellState(to: message.getMessageState(myUserId: myUserId))
            if let user = viewModel.getUser(for: message.fromUserId!) {
                
                cell?.updateSenderInfo(name: user.getDisplayName(), photoUrl: URL(string: user.getAvatarUrl() ?? ""))
            }
            return cell ?? UITableViewCell()
        }
        
        if message.type == "image" {
            var identifier = ""
            
            if myUserId == message.fromUserId! {
                identifier = ImageMessageTableViewCell.myImageReuseIdentifier
            } else if viewModel.room?.type == "private" {
                identifier = ImageMessageTableViewCell.friendImageReuseIdentifier
            } else {
                identifier = ImageMessageTableViewCell.groupImageReuseIdentifier
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ImageMessageTableViewCell
            cell?.updateCell(message: message)
            cell?.updateCellState(to: message.getMessageState(myUserId: myUserId))
            
            return cell ?? UITableViewCell()
        }
        
        return UITableViewCell()
    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(named: "videoCall"), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(named: "phoneCall"), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true

        if viewModel.room?.type == RoomType.privateRoom.rawValue {
            friendInfoView.change(avatarUrl: viewModel.friendUser.getAvatarUrl(), name: viewModel.friendUser.getDisplayName(), lastSeen: "yesterday")
        } else {
            friendInfoView.change(avatarUrl: viewModel.room?.getAvatarUrl(),
                                  name: viewModel.room?.name,
                                  lastSeen: "today")
        }
        
        let vtest = UIBarButtonItem(customView: friendInfoView)
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentChatViewController {
//        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//            let firstLeft = UIContextualAction(style: .normal, title: "Reply") { (action, view, completionHandler) in
//                self.currentChatView.messageInputView.showReplyView(view: ReplyMessageView(message: self.viewModel.messagesSubject.value[indexPath.row]), id: indexPath.row)
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

extension CurrentChatViewController: PHPickerViewControllerDelegate {
    
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
