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

struct SelectedFile {
    let fileType: MessageType
    let name: String?
    let fileUrl: URL
    let thumbnail: UIImage?
    let metaData: MetaData
    let mimeType: String
    let size: Int64?
}

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    private let userBlockedView = UserBlockedView(frame: .zero)
    private let offerToBlockUser = OfferToBlockUserView(frame: .zero)
    var viewModel: CurrentChatViewModel!
    private let friendInfoView = ChatNavigationBarView()
    private var frc: NSFetchedResultsController<MessageEntity>?
    private let audioPlayer = AudioPlayer()
    private var audioSubscribe: AnyCancellable?
    
    private let frcIsChangingPublisher = PassthroughSubject<FRCChangeType, Never>()
    private let frcDidChangePublisher = PassthroughSubject<Bool, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentChatView)
        setupNavigationItems()
        setupBindings()
        checkRoom()
        addSubviews()
        positionSubviews()
        self.navigationItem.backButtonTitle = self.viewModel.room?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let room = viewModel.room else { return }
        viewModel.roomVisited(roomId: room.id)
    }
    
    func addSubviews() {
        self.view.addSubview(userBlockedView)
        self.view.addSubview(offerToBlockUser)
    }
    
    func positionSubviews() {
        userBlockedView.constraintBottom()
        userBlockedView.constraintLeading()
        userBlockedView.constraintTrailing()
        
        offerToBlockUser.constraintBottom()
        offerToBlockUser.constraintLeading()
        offerToBlockUser.constraintTrailing()
    }
    
    deinit {
//        print("currentChatVC deinit")
    }
}

// MARK: Functions

extension CurrentChatViewController {
    func checkRoom() {
        viewModel.checkLocalRoom()
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let tableView = currentChatView.messagesTableView
        guard sender.state == .began,
              let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)),
              let entity = frc?.object(at: indexPath)
        else { return }
        let message = Message(messageEntity: entity)
        guard !message.deleted else { return }
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
            guard let selectedMessage = selectedMessage
            else {
                self?.currentChatView.messageInputView.hideReplyView()
                return
            }
            let senderName = self?.viewModel.room?.getDisplayNameFor(userId: selectedMessage.fromUserId)
            self?.currentChatView
                .messageInputView
                .showReplyView(senderName: senderName ?? .getStringFor(.unknown),
                               message: selectedMessage)
        }.store(in: &subscriptions)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        currentChatView.messagesTableView.addGestureRecognizer(longPress)
        
        viewModel.roomPublisher.receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] room in
                guard let self = self else { return }
                self.setFetch(room: room)
                self.setupNavigationItems()
                self.viewModel.sendSeenStatus()
            }.store(in: &self.subscriptions)
        
        currentChatView.downArrowImageView.tap().sink { [weak self] _ in
            self?.currentChatView.messagesTableView.scrollToBottom(.force)
        }.store(in: &self.subscriptions)
        
        Publishers
            .Zip(frcIsChangingPublisher, frcDidChangePublisher)
            .filter{$1}
            .sink { [weak self] (frcChange, frcDidChange) in
                guard let self = self else { return }
                
                switch frcChange {
                case .insert(indexPath: let indexPath):
                    guard let messageEntity = self.frc?.object(at: indexPath) else { return }
                    self.handleScroll(isMyMessage: messageEntity.fromUserId == self.viewModel.getMyUserId())
                case .other:
                    break
                }
            }.store(in: &subscriptions)
        
        self.viewModel.uploadProgressPublisher.receive(on: DispatchQueue.main).sink { [weak self] (uuid, percent, file) in
            guard let entity = self?.frc?.fetchedObjects?.first(where: { messageEntity in
                messageEntity.localId == uuid
            }),
                  let indexPath = self?.frc?.indexPath(forObject: entity),
                  let cell = self?.currentChatView.messagesTableView.cellForRow(at: indexPath)
            else { return }
            (cell as? BaseMessageTableViewCell)?.showUploadProgress(at: percent)
            
            if percent == 1.0 {
                (cell as? BaseMessageTableViewCell)?.hideUploadProgress()
            }
            guard let file = file else { return }
            (cell as? ImageMessageTableViewCell)?.setTempThumbnail(url: file.fileUrl, as: ImageRatio(width: file.metaData.width, height: file.metaData.height))
            (cell as? VideoMessageTableViewCell)?.setTempThumbnail(duration: "\(file.metaData.duration) s", url: file.fileUrl)
        }.store(in: &subscriptions)
        
        self.viewModel.isBlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBlocked in
                print("Is Blocked: \(isBlocked)")
                self?.userBlockedView.isHidden = !isBlocked
            }.store(in: &subscriptions)
        
        self.viewModel.offerToBlock
            .receive(on: DispatchQueue.main)
            .sink { offerToBlock in
                self.offerToBlockUser.isHidden = !offerToBlock
            }.store(in: &subscriptions)
        
        self.userBlockedView.blockUnblockButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.unblockUser()
            }.store(in: &subscriptions)
        
        self.offerToBlockUser.blockUnblockButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.offerToBlockUser.isHidden = true
                self?.viewModel.blockUser()
            }.store(in: &subscriptions)
        
        self.offerToBlockUser.okButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.offerToBlockUser.isHidden = true
                self?.viewModel.userConfirmed()
            }.store(in: &subscriptions)
    }
    
    func handleScroll(isMyMessage: Bool) {
        currentChatView.messagesTableView.scrollToBottom(isMyMessage ? .force : .ifLastCellVisible)
    }
}

// MARK: - NSFetchedResultsController

extension CurrentChatViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch(room: Room) {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: true),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "room.id == %d", room.id)
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: "sectionName", cacheName: nil)
        self.frc?.delegate = self
        do {
            try self.frc?.performFetch()
            self.currentChatView.messagesTableView.reloadData()
            self.currentChatView.messagesTableView.layoutIfNeeded()
            self.currentChatView.messagesTableView.scrollToBottom(.force)
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
        
        viewModel.roomVisited(roomId: room.id)
        
        let userId = self.viewModel.getMyUserId()
        guard let messages = self.frc?.sections?.first?.objects as? [MessageEntity],
              let _ = messages.first(where: { message in
                  message.fromUserId == userId
              }) else {
            self.viewModel.userRepliedInChat.send(false)
            return
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.beginUpdates()
    }
    
    // MARK: - sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("DIDCHANGE: sections insert")
            currentChatView.messagesTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("DIDCHANGE: sections delete")
            currentChatView.messagesTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("DIDCHANGE: sections move")
            break
        case .update:
            print("DIDCHANGE: sections update")
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            print("DIDCHANGE: rows insert")
            guard let newIndexPath = newIndexPath else {
                return
            }
            viewModel.sendSeenStatus()
            currentChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
            currentChatView.messagesTableView.reloadPreviousRow(for: newIndexPath)
            frcIsChangingPublisher.send(.insert(indexPath: newIndexPath))
            
        case .delete:
            print("DIDCHANGE: rows delete")
            guard let indexPath = indexPath else {
                return
            }
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
                UIView.performWithoutAnimation {
                    currentChatView.messagesTableView.reloadRows(at: [newIndexPath], with: .none)
                }
            } else {
                currentChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            }
            frcIsChangingPublisher.send(.other)
        
        case .update:
            print("DIDCHANGE: rows update")
            guard let indexPath = indexPath else {
                return
            }
            UIView.performWithoutAnimation {
                currentChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            }
            frcIsChangingPublisher.send(.other)
        
        default:
            frcIsChangingPublisher.send(.other)
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.endUpdates()
        frcDidChangePublisher.send(true)
    }
}


// MARK: - MessageInputView actions

extension CurrentChatViewController {
    
    func handleInput(_ state: MessageInputViewState) {
        switch state {
        case .plus:
            presentMoreActions()
        case .send(let inputText):
            viewModel.trySendMessage(text: inputText)
            currentChatView.messageInputView.clean()
        case .camera, .microphone:
            print(state, " in ccVC")
        case .emoji:
            print("emoji in ccvc")
        case .scrollToReply:
            guard let selectedMessageId = viewModel.selectedMessageToReplyPublisher.value?.id,
                  let indexPath = getIndexPathFor(messageId: selectedMessageId)
            else { return }
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        case .hideReply:
            viewModel.selectedMessageToReplyPublisher.send(nil)
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
            viewModel.showImage(link: url)
        case .scrollToReply:
            guard let replyId = message.replyId,
                  let indexPath = getIndexPathFor(messageId: replyId)
            else { return }
            currentChatView.messagesTableView.blinkRow(at: indexPath)
        case .showReactions:
            viewModel.showReactions(records: message.getMessageReactionsRecords() ?? [])
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let lastIndexPath = tableView.lastCellIndexPath,
              let shouldHide = tableView.indexPathsForVisibleRows?.contains(lastIndexPath)
        else { return }
        currentChatView.hideScrollToBottomButton(should: shouldHide)
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entity = frc?.object(at: indexPath),
              let roomType = viewModel.room?.type
        else { return EmptyTableViewCell()}

        let message = Message(messageEntity: entity)
        let myUserId = viewModel.getMyUserId()
        
        guard let identifier = message.getReuseIdentifier(myUserId: myUserId, roomType: roomType),
              let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseMessageTableViewCell,
              let senderType = cell.getMessageSenderType(reuseIdentifier: identifier)
        else { return EmptyTableViewCell() }
        
        if let user = viewModel.getUser(for: message.fromUserId) {
            if !isPreviousCellMine(for: indexPath) {
                cell.updateSender(name: user.getDisplayName())
            }
            if !isNextCellMine(for: indexPath) {
                cell.updateSender(photoUrl: user.avatarFileId?.fullFilePathFromId())
            }
        }
        
        guard !message.deleted
        else {
            (cell as? DeletedMessageTableViewCell)?.updateCell(message: message)
            return cell
        }
        
        if let replyId = message.replyId, replyId >= 0,
           let repliedMessageEntity = frc?.fetchedObjects?.first(where: { $0.id == "\(replyId)" })
        {
            let repliedMessage = Message(messageEntity: repliedMessageEntity)
            let senderName = viewModel.room?.getDisplayNameFor(userId: repliedMessage.fromUserId)
            
            cell.showReplyView(senderName: senderName ?? .getStringFor(.unknown),
                               message: repliedMessage,
                               sender: senderType)
        }
        
        if let reactionsRecords = message.getMessageReactionsRecords() {
            cell.showReactions(reactionRecords: reactionsRecords)
        }
        
        (cell as? BaseMessageTableViewCellProtocol)?.updateCell(message: message)
        
        cell.tapPublisher.sink(receiveValue: { [weak self] state in
            self?.handleCellTap(state, message: message)
        }).store(in: &cell.subs)
        
        cell.updateCellState(to: message.getMessageState(myUserId: myUserId))
        cell.updateTime(to: message.createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = self.frc?.sections else { return nil }
        var name = sections[section].name
        if let time = (sections[section].objects?.first as? MessageEntity)?.createdAt {
            name.append(", ")
            name.append(time.convert(to: .HHmm))
        }
        let dateLabel = CustomLabel(text: name, textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
        return dateLabel
    }
    
    func isPreviousCellMine(for indexPath: IndexPath) -> Bool {
        let previousRow = indexPath.row - 1
        if previousRow >= 0 {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let previousMessageEntity = frc?.object(at: IndexPath(row: previousRow,
                                                                  section: indexPath.section))
            return currentMessageEntity?.fromUserId == previousMessageEntity?.fromUserId
        }
        return false
    }
    
    func isNextCellMine(for indexPath: IndexPath) -> Bool {
        guard let sections = frc?.sections else { return true }
        let maxRowsIndex = sections[indexPath.section].numberOfObjects - 1
        let nextRow = indexPath.row + 1
        if nextRow <= maxRowsIndex {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let nextMessageEntity = frc?.object(at: IndexPath(row: nextRow,
                                                              section: indexPath.section))
            return currentMessageEntity?.fromUserId == nextMessageEntity?.fromUserId
        }
        return false
    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(safeImage: .videoCall), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(safeImage: .phoneCall), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true
        
        if viewModel.room?.type == .privateRoom {
            friendInfoView.change(avatarUrl: viewModel.friendUser?.avatarFileId?.fullFilePathFromId(), name: viewModel.friendUser?.getDisplayName(), lastSeen: .getStringFor(.yesterday))
        } else {
            friendInfoView.change(avatarUrl: viewModel.room?.avatarFileId?.fullFilePathFromId(),
                                  name: viewModel.room?.name,
                                  lastSeen: .getStringFor(.today))
        }
        
        let vtest = UIBarButtonItem(customView: friendInfoView)
        friendInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChatDetails)))
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func onChatDetails() {
        guard let room = self.viewModel.room else { return }
        let publisher = CurrentValueSubject<Room,Never>(room)
        
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
        guard let messageEntity = frc?.object(at: indexPath) else { return nil }
        let message = Message(messageEntity: messageEntity)
        guard !message.deleted,
              let records = message.records
        else { return nil}
              
        let firstRight = UIContextualAction(style: .normal, title: .getStringFor(.details)) { [weak self] (action, view, completionHandler) in
            self?.viewModel.presentMessageDetails(records: records)
            completionHandler(true)
        }
        firstRight.backgroundColor = .logoBlue
        firstRight.image = UIImage(safeImage: .detailsMessage)
        return UISwipeActionsConfiguration(actions: [firstRight])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let messageEntity = frc?.object(at: indexPath) else { return nil }
        let message = Message(messageEntity: messageEntity)
        guard !message.deleted else { return nil }
        
        let firstLeft = UIContextualAction(style: .normal, title: .getStringFor(.reply)) { [weak self] (action, view, completionHandler) in

            let senderName = self?.viewModel.room?.getDisplayNameFor(userId: message.fromUserId)
            self?.viewModel.selectedMessageToReplyPublisher.send(message)
            self?.currentChatView.messageInputView.showReplyView(senderName: senderName ?? .getStringFor(.unknown), message: message)
            completionHandler(true)
        }
        firstLeft.backgroundColor = .logoBlue
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

extension CurrentChatViewController {
    private func getIndexPathFor(messageId id: Int64) -> IndexPath? {
        guard let entity = frc?.fetchedObjects?.first(where: { $0.id == "\(id)" })
        else { return nil }
        return frc?.indexPath(forObject: entity)
    }
}
