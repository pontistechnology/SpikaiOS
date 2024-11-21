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
import Combine
import UniformTypeIdentifiers

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    var viewModel: CurrentChatViewModel!
    private let friendInfoView = ChatNavigationBarView()
    
    private let audioPlayer = AudioPlayer()
    private var audioSubscribe: AnyCancellable?
    
    private let frcIsChangingPublisher = PassthroughSubject<FRCChangeType, Never>()
    private let frcDidChangePublisher = PassthroughSubject<Bool, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colors: UIColor._backgroundGradientColors)
        view.addSubview(currentChatView)
        currentChatView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .zero)
        setupBindings()
        //        self.navigationItem.backButtonTitle = self.viewModel.room.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupNavigationItems()
        viewModel.sendSeenStatus()
    }
    
    deinit {
        print("currentChatVC deinit")
    }
}

// MARK: Functions

extension CurrentChatViewController {
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let tableView = currentChatView.messagesTableView
        guard sender.state == .began,
              let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)),
              let message = viewModel.getMessage(for: indexPath),
              message.type != .system
        else { return }
        viewModel.showMessageActions(message)
    }
    
    func setupBindings() {
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
        
        sink(networkRequestState: viewModel.networkRequestState)
        
        currentChatView.messageInputView.inputViewTapPublisher.sink { [weak self] state in
            self?.handleInput(state)
        }.store(in: &subscriptions)
        
        viewModel.selectedMessageToReplyPublisher.receive(on: DispatchQueue.main).sink { [weak self] selectedMessage in
            guard let selectedMessage
            else {
                self?.currentChatView.messageInputView.hideReplyView()
                return
            }
            let senderName = self?.viewModel.room.getDisplayNameFor(userId: selectedMessage.fromUserId) // todo function
            self?.currentChatView
                .messageInputView
                .showReplyView(senderName: senderName ?? .getStringFor(.unknown),
                               message: selectedMessage)
        }.store(in: &subscriptions)
        
        viewModel.selectedMessageToEditPublisher.sink { [weak self] selectedMessage in
            guard let text = selectedMessage?.body?.text
            else {
                self?.currentChatView.messageInputView.currentStatePublisher.send(.empty)
                return
            }
            self?.currentChatView.messageInputView.currentStatePublisher.send(.editing(text))
        }.store(in: &subscriptions)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.15
        currentChatView.messagesTableView.addGestureRecognizer(longPress)
        
        currentChatView.scrollToBottomStackView.tap().sink { [weak self] _ in
            guard let self else { return }
            self.currentChatView.messagesTableView.scrollToBottom(.force(animated: true))
            self.currentChatView.handleScrollToBottomButton(show: false, number: self.viewModel.numberOfUnreadMessages.value)
        }.store(in: &subscriptions)
        
        viewModel.numberOfUnreadMessages.sink { [weak self] number in
            self?.currentChatView.handleScrollToBottomButton(show: number > 0, number: number)
        }.store(in: &subscriptions)
        
        currentChatView.messageInputView.inputTextAndControlsView.keyboardAccessoryView.publisher.sink { _ in
            
        } receiveValue: { [weak self] distance in
            self?.currentChatView.moveInputFromBottom(for: distance)
        }.store(in: &subscriptions)
        
        Publishers
            .Zip(frcIsChangingPublisher, frcDidChangePublisher)
            .receive(on: DispatchQueue.main)
            .filter{$1}
            .sink { [weak self] (frcChange, frcDidChange) in
                guard let self else { return }
                
                switch frcChange {
                case .insert(indexPath: let indexPath):
                    guard let message = self.viewModel.getMessage(for: indexPath) else { return }
                    let isMyMessage = message.fromUserId == self.viewModel.myUserId
                    self.handleScroll(isMyMessage: isMyMessage)
                    if self.viewModel.room.type == .groupRoom && !isMyMessage {
                        if self.viewModel.isPreviousCellSameSender(for: indexPath) {
                            self.currentChatView.messagesTableView.reloadPreviousRow(for: indexPath)
                        }
                    }
                    if !isMyMessage && self.currentChatView.messagesTableView.distanceFromBottom() > 50 {
                        self.viewModel.numberOfUnreadMessages.send(self.viewModel.numberOfUnreadMessages.value + 1)
                    }
                case .other:
                    break
                }
            }.store(in: &subscriptions)
        
        self.viewModel.uploadProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uuid in
                guard let percentUploaded = self?.viewModel.uploadsInProgress[uuid],
                      let indexPath = self?.viewModel.getIndexPathFor(localId: uuid),
                      let cell = self?.currentChatView.messagesTableView.cellForRow(at: indexPath)
                else { return }
                (cell as? BaseMessageTableViewCell2)?.showUploadProgress(at: percentUploaded)
                    
                if percentUploaded == 1.0 {
                    (cell as? BaseMessageTableViewCell2)?.hideUploadProgress()
                }
        }.store(in: &subscriptions)
        
        self.imagePickerPublisher.sink { [weak self] pickedImage in

            self?.viewModel.sendCameraImage(pickedImage)
        }.store(in: &subscriptions)
        
        // TODO: fetch isBlocked and delete input field
        
//        viewModel.paginationPublisher.receive(on: DispatchQueue.main).sink { [weak self] direction in
//            guard let self else { return }
//            let messageId: String? = switch direction {
//            case .up:
//                viewModel.frc?.fetchedObjects?.first?.id
//            case .down:
//                viewModel.frc?.fetchedObjects?.last?.id
//            case .initial:
//                nil
//            }
//            
//            // Reload your table view with your new messages
//            viewModel.setFetch(direction)
//            currentChatView.messagesTableView.reloadData()
//            
//            switch direction {
//            case .up:
//                guard let sameMessage = viewModel.frc?.fetchedObjects?.first(where: { mE in
//                    mE.id == messageId
//                }),
//                      let iP = viewModel.frc?.indexPath(forObject: sameMessage)
//                else { return }
//                currentChatView.messagesTableView.scrollToRow(at: iP, at: .top, animated: false)
//            case .down:
//                guard let sameMessage = viewModel.frc?.fetchedObjects?.first(where: { mE in
//                    mE.id == messageId
//                }),
//                      let iP = viewModel.frc?.indexPath(forObject: sameMessage)
//                else { return }
//                currentChatView.messagesTableView.scrollToRow(at: iP, at: .bottom, animated: false)
//            case .initial:
//                currentChatView.messagesTableView.scrollToBottom(.force(animated: false))
//            }
//            
//            
//        }.store(in: &subscriptions)
        currentChatView.messagesTableView.hide()
        viewModel.setFetch(.initial)
        
        viewModel.messagesFRC?.delegate = self
        if let messageId = viewModel.scrollToMessageId,
           let indexPath = viewModel.getIndexPathFor(messageId: messageId) {
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        } else {
            currentChatView.messagesTableView.scrollToBottom(.force(animated: false))
        }
        
        currentChatView.messagesTableView.unhide()
        
        var ids: [Int64] = []
        
        viewModel.messagesFRC?.fetchedObjects?
            .forEach({ messageEntity in
                if let id = messageEntity.id,
                   let number = Int64(id) {
                    ids.append(number)
                }
            })
        
        viewModel.loadReactions(messageIds: ids)
        viewModel.loadFilesData()
        
        test()
    }
    
    func handleScroll(isMyMessage: Bool) {
        currentChatView.messagesTableView.scrollToBottom(isMyMessage ? .force(animated: true) : .ifLastCellVisible)
    }
}

extension CurrentChatViewController {
    func test() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            // TODO: - not always correctly reloaded, maybe if not fully visible?
            if let visibleRows = currentChatView.messagesTableView.indexPathsForVisibleRows {
                currentChatView.messagesTableView.reloadRows(at: visibleRows, with: .none)
            }
        }
    }
}

extension CurrentChatViewController {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        checkIfUserIsOnTopOfScrollView(scrollView)
//    }
//    
//    func checkIfUserIsOnTopOfScrollView(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < 70 {
//            viewModel.paginationPublisher.send(.up)
//        }
//        
//        if scrollView.distanceFromBottom() < 100 {
//            viewModel.paginationPublisher.send(.down)
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentChatView.messagesTableView.distanceFromBottom() < 50 {
            viewModel.numberOfUnreadMessages.send(0)
        } else {
            currentChatView.handleScrollToBottomButton(show: true, number: viewModel.numberOfUnreadMessages.value)
        }
    }
}

// MARK: - NSFetchedResultsController

extension CurrentChatViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            currentChatView.messagesTableView.beginUpdates()
    }
    
    // MARK: - sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
                currentChatView.messagesTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
                currentChatView.messagesTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            viewModel.sendSeenStatus()
            currentChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
            frcIsChangingPublisher.send(.insert(indexPath: newIndexPath))
            
        case .delete:
            guard let indexPath = indexPath else { return }
            currentChatView.messagesTableView.deleteRows(at: [indexPath], with: .none)
            frcIsChangingPublisher.send(.other)
        
        case .move:
            // this is called instead of .update when there is only one object in section
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            if indexPath == newIndexPath {
                currentChatView.messagesTableView.reloadRows(at: [newIndexPath], with: .none)
            } else {
                currentChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            }
            frcIsChangingPublisher.send(.other)
        
        case .update:
            guard let indexPath = indexPath else { return }
            currentChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            frcIsChangingPublisher.send(.other)
        
        default:
            frcIsChangingPublisher.send(.other)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.endUpdates()
        frcDidChangePublisher.send(true)
        
        if controller == viewModel.reactionsFRC {
            test()
        }
    }
}


// MARK: - MessageInputView actions

extension CurrentChatViewController {
    
    func handleInput(_ state: MessageInputViewButtonAction) {
        switch state {
        case .plus:
            presentMoreActions()
        case .send(let inputText):
            viewModel.trySendMessage(text: inputText)
            currentChatView.messageInputView.clean()
        case .camera, .microphone:
            view.endEditing(true) // hiding keyboard, because otherwise it will be empty space instead of keyboard when you get back to this screen
            showUIImagePicker(source: .camera, allowsEdit: false)
        case .scrollToReply:
            guard let selectedMessageId = viewModel.selectedMessageToReplyPublisher.value?.id,
                  let indexPath = viewModel.getIndexPathFor(messageId: selectedMessageId)
            else { return }
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        case .hideReply:
            viewModel.selectedMessageToReplyPublisher.send(nil)
        case .save(let inputText):
            viewModel.editSelectedMessage(text: inputText)
        case .cancelEditing:
            viewModel.selectedMessageToEditPublisher.send(nil)
        default:
            break
        }
    }
}

// MARK: - MessageCell actions

extension CurrentChatViewController {
    func handleCellTap(_ state: MessageCellTaps, message: Message) {
        switch state {
        case .playVideo:
            viewModel.playVideo(message: message)
        case let .playAudio(playedPercentPublisher):
            guard let url = message.body?.file?.id?.fullFilePathFromId(),
                  let mimeType = message.body?.file?.mimeType
            else { return }
            audioSubscribe?.cancel()
            audioSubscribe = audioPlayer
                .playAudio(url: url, mimeType: mimeType)?
                .sink { [weak self] percent in
                playedPercentPublisher.send(percent)
            }
            audioSubscribe?.store(in: &subscriptions)
        case .openImage:
            guard let url = message.body?.file?.id?.fullFilePathFromId() else { return }
            viewModel.showImage(message: message)
        case .scrollToReply:
            guard let replyId = message.replyId,
                  let indexPath = viewModel.getIndexPathFor(messageId: replyId)
            else { return }
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        case .showReactions:
            viewModel.showReactions(records: message.reactionRecords)
        case .openFile:
            viewModel.openFile(message: message)
        }
    }
}

// MARK: - UITableView

extension CurrentChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseMessageTableViewCell2 else { return }
        (tableView.visibleCells as? [BaseMessageTableViewCell2])?.forEach{ $0.setTimeLabelVisible(false)}
        tableView.beginUpdates()
        cell.tapHandler()
        tableView.endUpdates()
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.messagesFRC?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = viewModel.messagesFRC?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("DEBUGPRINT: fetcham cell za indexpath: ", indexPath)
        guard let message = viewModel.getMessage(for: indexPath)
        else { return UnknownTableViewCell()}
        let myUserId = viewModel.myUserId
        let isMyMessage = message.fromUserId == myUserId
        
        guard let identifier = message.getReuseIdentifier2() else {
            return UnknownTableViewCell()
        }
        
        guard message.type != .system else {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SystemMessageTableViewCell
            cell?.updateCell(attributedString: viewModel.room.getAttributedStringForSystemMessage(message: message))
            return cell ?? UnknownTableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseMessageTableViewCell2
        else {
            return UnknownTableViewCell()
        }
        
        cell.setupContainer(sender: viewModel.getSenderTypeFor(message: message))
        
        if let user = viewModel.getUser(for: message.fromUserId),
            viewModel.room.type == .groupRoom {
            if !viewModel.isPreviousCellSameSender(for: indexPath) {
                cell.updateSender(name: user.getDisplayName(),
                                  isMyMessage: isMyMessage)
            }
            if !viewModel.isNextCellSameSender(for: indexPath) {
                cell.updateSender(photoUrl: user.avatarFileId?.fullFilePathFromId(),
                                  isMyMessage: isMyMessage)
            }
        }
        
        guard !message.deleted
        else {
            (cell as? DeletedMessageTableViewCell)?.updateCell(message: message)
            return cell
        }
        // Do not add anything before this, because message can be deleted
        
        if let replyId = message.replyId,
           let repliedMessageIndexPath = viewModel.getIndexPathFor(messageId: replyId),
           let repliedMessage = viewModel.getMessage(for: repliedMessageIndexPath)
        {
            let senderName = viewModel.room.getDisplayNameFor(userId: repliedMessage.fromUserId)
            cell.showReplyView(senderName: senderName,
                               message: repliedMessage,
                               sender: isMyMessage ? .me : .friend)
        }
        
        cell.showReactionEditedAndCheckMark(reactionRecords: message.reactionRecords, isEdited: message.modifiedAt != message.createdAt, messageState: message.getMessageState(myUserId: myUserId), isForTextCell: message.type == .text, isMyMessage: message.fromUserId == myUserId, isForwarded: message.isForwarded)
        
        (cell as? BaseMessageTableViewCellProtocol)?.updateCell(message: message)
        
        if viewModel.compressionsInProgress.contains(where: { $0 == message.localId }) {
            cell.startSpinning()
        }
    
        if let localId = message.localId, let percentUploaded = viewModel.uploadsInProgress[localId] {
            percentUploaded < 1 ? cell.showUploadProgress(at: percentUploaded) : cell.hideUploadProgress()
        }
        
        cell.tapPublisher.sink(receiveValue: { [weak self] state in
            self?.handleCellTap(state, message: message)
        }).store(in: &cell.subs)
        
        cell.updateTime(to: message.createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let nameOfSection = viewModel.getNameForSection(section: section) else {
            return nil
        }
//        let text: String
//        if section == 0 && viewModel.currentOffset != 0 {
//            text = "Loading older messages..."
//        } else {
//            text = nameOfSection
//        }
        return CustomLabel(text: nameOfSection, textSize: 11, textColor: .textPrimary, fontName: .RobotoFlexMedium, alignment: .center)
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == (viewModel.frc?.sections?.count ?? 0) - 1
//            && (viewModel.currentOffset + 2*viewModel.fetchLimit < viewModel.countOfAllMessages) {
    //            return CustomLabel(text: "Loading newer messages...", textSize: 11, textColor: .textPrimary, fontName: .RobotoFlexMedium, alignment: .center)
//        return nil
//    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
//        let videoCallButton = UIBarButtonItem(image: UIImage(resource: .videoCall), style: .plain, target: self, action: #selector(videoCallActionHandler))
//        let audioCallButton = UIBarButtonItem(image: UIImage(resource: .phoneCall), style: .plain, target: self, action: #selector(phoneCallActionHandler))
//        
//        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true
        
        if viewModel.room.type == .privateRoom {
            friendInfoView.change(avatarUrl: viewModel.friendUser?.avatarFileId?.fullFilePathFromId(), name: viewModel.friendUser?.getDisplayName(), lastSeen: viewModel.friendUser?.telephoneNumber ?? "")
        } else {
            friendInfoView.change(avatarUrl: viewModel.room.avatarFileId?.fullFilePathFromId(),
                                  name: viewModel.room.name,
                                  lastSeen: "\(viewModel.room.users.count) members")
            // TODO: - will be changed to last seen, then move to localization
        }
        
        let vtest = UIBarButtonItem(customView: friendInfoView)
        friendInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatDetails)))
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func onChatDetails() {
        let publisher = CurrentValueSubject<Room, Never>(viewModel.room)
        publisher.sink { [weak self] newRoom in
            self?.viewModel.room = newRoom
        }.store(in: &subscriptions)
        
        if viewModel.room.type == .privateRoom,
            let friendUser = viewModel.friendUser {
            viewModel.getAppCoordinator()?.presentChatDetailsScreen(detailsMode: .contact(friendUser))
        } else {
            viewModel.getAppCoordinator()?.presentChatDetailsScreen(detailsMode: .roomDetails(publisher))            
        }
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentChatViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let message = viewModel.getMessage(for: indexPath), message.type != .system else { return nil }
        guard !message.deleted else { return nil}
        // TODO: - refactor this to seperate view
        let detailsAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.viewModel.presentMessageDetails(for: indexPath)
            completionHandler(true)
        }
//        detailsAction.backgroundColor = ._primaryColor // TODO: -check
        detailsAction.image = UIImage(resource: .slideDetails)
        return UISwipeActionsConfiguration(actions: [detailsAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let message = viewModel.getMessage(for: indexPath), message.type != .system else { return nil }
        guard !message.deleted else { return nil }
        //  TODO: refacotr
        let firstLeft = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in

            let senderName = self?.viewModel.room.getDisplayNameFor(userId: message.fromUserId)
            self?.viewModel.selectedMessageToReplyPublisher.send(message)
            self?.currentChatView.messageInputView.showReplyView(senderName: senderName ?? .getStringFor(.unknown), message: message)
            completionHandler(true)
        }
//        firstLeft.backgroundColor = ._primaryColor // TODO: - check
        firstLeft.image = UIImage(resource: .slideReply)
        return UISwipeActionsConfiguration(actions: [firstLeft])
    }
    
}

// MARK: - More Actions Bottom Sheet

private extension CurrentChatViewController {
    func presentMoreActions() {
        viewModel.presentMoreActions()?.sink(receiveValue: { [weak self] state in
            self?.dismiss(animated: true)
            switch state {
            case .files:
                self?.presentFilePicker()
            case .library:
                self?.presentLibraryPicker()
            case .location, .contact, .close:
                break
            }
        }).store(in: &subscriptions)
    }
}

// MARK: - Photo Video picker

extension CurrentChatViewController: PHPickerViewControllerDelegate {
    
    func presentLibraryPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = .any(of: [.images, .livePhotos, .videos]) // TODO: check
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 30
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        viewModel.sendMultimedia(results)
    }
}

// MARK: - File picker

extension CurrentChatViewController: UIDocumentPickerDelegate {
    func presentFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        viewModel.sendDocuments(urls: urls)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
