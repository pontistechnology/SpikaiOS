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
        setupView(currentChatView)
        setupNavigationItems()
        setupBindings()
        self.navigationItem.backButtonTitle = self.viewModel.room.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
              let message = viewModel.getMessage(for: indexPath)
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
        
        viewModel.selectedMessageToReplyPublisher.sink { [weak self] selectedMessage in
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
        currentChatView.messagesTableView.addGestureRecognizer(longPress)
        
        currentChatView.scrollToBottomStackView.tap().sink { [weak self] _ in
            guard let self else { return }
            self.currentChatView.messagesTableView.scrollToBottom(.force(animated: true))
            self.currentChatView.handleScrollToBottomButton(show: false, number: self.viewModel.numberOfUnreadMessages.value)
        }.store(in: &subscriptions)
        
        viewModel.numberOfUnreadMessages.sink { [weak self] number in
            self?.currentChatView.handleScrollToBottomButton(show: number > 0, number: number)
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
                    let isMyMessage = message.fromUserId == self.viewModel.getMyUserId()
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
                (cell as? BaseMessageTableViewCell)?.showUploadProgress(at: percentUploaded)
                    
                if percentUploaded == 1.0 {
                    (cell as? BaseMessageTableViewCell)?.hideUploadProgress()
                }
        }.store(in: &subscriptions)
        
        self.imagePickerPublisher.sink { [weak self] pickedImage in

            self?.viewModel.sendCameraImage(pickedImage)
        }.store(in: &subscriptions)
        
        // TODO: fetch is blocked and delete input field
        
        viewModel.setFetch()
        viewModel.frc?.delegate = self
        currentChatView.messagesTableView.scrollToBottom(.force(animated: false))
    }
    
    func handleScroll(isMyMessage: Bool) {
        currentChatView.messagesTableView.scrollToBottom(isMyMessage ? .force(animated: true) : .ifLastCellVisible)
    }
}

extension CurrentChatViewController {
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
            print(state, " in ccVC")
            showUIImagePicker(source: .camera, allowsEdit: false)
        case .emoji:
            print("emoji in ccvc")
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
            viewModel.showReactions(records: message.records ?? []) // TODO: change maybe to vm
        case .openFile:
            viewModel.openFile(message: message)
        }
    }
}

// MARK: - UITableView

extension CurrentChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseMessageTableViewCell else { return }
        (tableView.visibleCells as? [BaseMessageTableViewCell])?.forEach{ $0.setTimeLabelVisible(false)}
        cell.tapHandler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.frc?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = viewModel.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel.getMessage(for: indexPath)
        else { return EmptyTableViewCell()}
        let roomType = viewModel.room.type

        let myUserId = viewModel.getMyUserId()
        
        guard let identifier = message.getReuseIdentifier(myUserId: myUserId, roomType: roomType),
              let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseMessageTableViewCell,
              let senderType = cell.getMessageSenderType(reuseIdentifier: identifier)
        else { return EmptyTableViewCell() }
        
        if let user = viewModel.getUser(for: message.fromUserId),
            viewModel.room.type == .groupRoom {
            if !viewModel.isPreviousCellSameSender(for: indexPath) {
                cell.updateSender(name: user.getDisplayName())
            }
            if !viewModel.isNextCellSameSender(for: indexPath) {
                cell.updateSender(photoUrl: user.avatarFileId?.fullFilePathFromId())
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
                               sender: senderType)
        }
        
        if let reactionsRecords = message.records {
            cell.showReactions(reactionRecords: reactionsRecords)
        }
        
        if message.modifiedAt != message.createdAt {
            cell.showEditedIcon()
        }
        
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
        
        if message.fromUserId == myUserId {
            cell.updateCellState(to: message.getMessageState(myUserId: myUserId))
        }
        cell.updateTime(to: message.createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let nameOfSection = viewModel.getNameForSection(section: section) else {
            return nil
        }
        return CustomLabel(text: nameOfSection, textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(safeImage: .videoCall), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(safeImage: .phoneCall), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
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
        }.store(in: &self.subscriptions)
        
        self.viewModel.getAppCoordinator()?.presentChatDetailsScreen(room: publisher)
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentChatViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let message = viewModel.getMessage(for: indexPath) else { return nil }
        guard !message.deleted else { return nil}
        // TODO: - refactor this to seperate view
        let detailsAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.viewModel.presentMessageDetails(for: indexPath)
            completionHandler(true)
        }
        detailsAction.backgroundColor = .primaryBackground
        detailsAction.image = UIImage(safeImage: .slideDetails)
        
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.viewModel.showDeleteConfirmDialog(message: message)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .primaryBackground
        deleteAction.image = UIImage(safeImage: .slideDelete)
        return UISwipeActionsConfiguration(actions: [detailsAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let message = viewModel.getMessage(for: indexPath) else { return nil }
        guard !message.deleted else { return nil }
        //  TODO: refacotr
        let firstLeft = UIContextualAction(style: .normal, title: .getStringFor(.reply)) { [weak self] (action, view, completionHandler) in

            let senderName = self?.viewModel.room.getDisplayNameFor(userId: message.fromUserId)
            self?.viewModel.selectedMessageToReplyPublisher.send(message)
            self?.currentChatView.messageInputView.showReplyView(senderName: senderName ?? .getStringFor(.unknown), message: message)
            completionHandler(true)
        }
        firstLeft.backgroundColor = .primaryBackground
        firstLeft.image = UIImage(safeImage: .slideReply)
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
