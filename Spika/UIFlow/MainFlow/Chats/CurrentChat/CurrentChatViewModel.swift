//
//  CurrentPrivateChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine
import CoreData
import IKEventSource
import AVFoundation
import PhotosUI

struct UploadProgess: Hashable {
    let uuid: String
    let percentUploaded: CGFloat
}

enum PagionationDirection {
    case up, down, initial
}

class CurrentChatViewModel: BaseViewModel {
    
    var messagesFRC: NSFetchedResultsController<MessageEntity>?
    var reactionsFRC: NSFetchedResultsController<MessageRecordEntity>?
    var filesFRC: NSFetchedResultsController<FileEntity>?
    var room: Room
    
    var friendUser: User? {
        room.getFriendUserInPrivateRoom(myUserId: myUserId)
    }
    
    let uploadProgressPublisher = PassthroughSubject<String, Never>()
    
    var compressionsInProgress = Set<String>()
    var uploadsInProgress: [String : CGFloat] = [:]
    
    let selectedMessageToReplyPublisher = CurrentValueSubject<Message?, Never>(nil)
    let selectedMessageToEditPublisher = CurrentValueSubject<Message?, Never>(nil)
    let numberOfUnreadMessages = CurrentValueSubject<Int, Never>(0)
    
    let scrollToMessageId: Int64?
    
//    let paginationPublisher = CurrentValueSubject<PagionationDirection, Never>(.initial)
//    var currentOffset = -1 // this should never happen
//    var countOfAllMessages = 0
//    let fetchLimit = 50
    
    init(repository: Repository, coordinator: Coordinator, room: Room, scrollToMessageId: Int64?, actionPublisher: ActionPublisher) {
        self.scrollToMessageId = scrollToMessageId
        self.room = room
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        setupBindings()
//        getCountOfAllMessages()
    }
    
    func setupBindings() {
        actionPublisher?.sink(receiveValue: { [weak self] action in
            switch action {
            case .updateRoom(let room):
                self?.room = room
            default:
                break
            }
        }).store(in: &subscriptions)
    }
    
    func getSenderTypeFor(message: Message) -> MessageSender {
        if message.fromUserId == myUserId {
            return .me
        } else {
            return room.type == .groupRoom ? .group : .friend
        }
    }
}

extension CurrentChatViewModel {
    func loadReactions(messageIds: [Int64]) {
        let fetchRequest = MessageRecordEntity.fetchRequest()
        let currentTimestamp = Date().currentTimeMillis()
        // fetch all reactions for all messages in this room, and continue fetching all reactions (we dont have roomId in MessageRecord, so for live update it will fetch some unnecessary reaction, but only when in chat)
        fetchRequest.predicate = NSPredicate(format: "type == %@ AND (messageId IN %@ OR modifiedAt > %ld )", MessageRecordType.reaction.rawValue, messageIds, currentTimestamp)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MessageRecordEntity.type), ascending: true)]
        self.reactionsFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        self.reactionsFRC?.delegate = self
        do {
            try self.reactionsFRC?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
    }
    
    func loadFilesData() {
        let fetchRequest = FileEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FileEntity.localId), ascending: true)]
        self.filesFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        self.filesFRC?.delegate = self
        do {
            try self.filesFRC?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
    }
}

extension CurrentChatViewModel: NSFetchedResultsControllerDelegate {
}

// MARK: - Navigation
extension CurrentChatViewModel {
    func popTopViewController() {
        getAppCoordinator()?.popTopViewController()
    }
    
    func presentMessageDetails(for indexPath: IndexPath) {
        guard let message = getMessage(for: indexPath) else { return }
        let users = room.users.compactMap { $0.user }
        getAppCoordinator()?.presentMessageDetails(users: users, message: message)
    }
    
    func presentMoreActions() -> PassthroughSubject<MoreActions, Never>? {
        return getAppCoordinator()?.presentMoreActionsSheet()
    }
    
    func playVideo(message: Message) {
        // TODO: - move to repo file manager logic?
        if let localId = message.localId,
           let localUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(localId).appendingPathExtension("mp4"),
           FileManager.default.fileExists(atPath: localUrl.path) {
            let asset = AVAsset(url: localUrl)
            getAppCoordinator()?.presentAVVideoController(asset: asset)
        } else {
            guard let url = message.body?.file?.id?.fullFilePathFromId(),
                  let mimeType = message.body?.file?.mimeType
            else { return }
            let asset = AVURLAsset(url: url, mimeType: mimeType)
            getAppCoordinator()?.presentAVVideoController(asset: asset)
        }
    }
    
    func showImage(message: Message) {
        getAppCoordinator()?.presentImageViewer(message: message)
    }
    
    func showReactions(records: [MessageRecord]) {
        let users = room.users.compactMap { roomUser in
            roomUser.user
        }
        getAppCoordinator()?.presentReactionsSheet(users: users, records: records, myId: myUserId)
    }
    
    func showCustomReactionPicker(message: Message) {
        getAppCoordinator()?.presentCustomReactionPicker()
            .sink(receiveValue: { [weak self] emoji in
                guard let id = message.id else { return }
                self?.sendReaction(reaction: emoji, messageId: id)
            }).store(in: &subscriptions)
    }
    
    // TODO: add indexpath
    func showMessageActions(_ message: Message) {
        guard !message.deleted else { return }
        let actions: [MessageAction] =
        if message.fromUserId == myUserId && message.type == .text && !message.isForwarded {
            [.reply, .forward, .copy, .edit, .details, .favorite, .delete].shuffled()
        } else {
            [.reply, .forward, (message.type == .image ? .download : .copy ), .details, .favorite, .delete].shuffled()
        }
        
        getAppCoordinator()?
            .presentMessageActionsSheet(actions: actions)
            .sink(receiveValue: { [weak self] action in
                guard let self else { return }
                self.getAppCoordinator()?.dismissViewController()
                guard let id = message.id else { return }
                switch action {
                case .reaction(emoji: let emoji):
                    sendReaction(reaction: emoji, messageId: id)
                case .reply:
                    selectedMessageToReplyPublisher.send(message)
                case .copy:
                    UIPasteboard.general.string = message.body?.text
                    showOneSecAlert(type: .copy)
                case .details:
                    let users = self.room.users.compactMap { $0.user }
                    self.getAppCoordinator()?.presentMessageDetails(users: users, message: message)
                case .delete:
                    self.showDeleteConfirmDialog(message: message)
                case .edit:
                    self.selectedMessageToEditPublisher.send(message)
                case .showCustomReactions:
                    self.showCustomReactionPicker(message: message)
                case .forward:
                    guard let messageId = message.id else { return }
                    getAppCoordinator()?.presentForwardScreen(ids: [messageId], context: repository.getMainContext())
                case .download:
                    guard let url = message.body?.file?.id?.fullFilePathFromId(),
                          let data = try? Data(contentsOf: url),
                          let uiimage = UIImage(data: data)
                    else { return }
                    UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(saveCompleted), nil)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func editSelectedMessage(text: String) {
        guard let id = selectedMessageToEditPublisher.value?.id else { return }
        selectedMessageToEditPublisher.send(nil)
        repository.updateMessage(messageId: id, text: text).sink { c in
        } receiveValue: { [weak self] response in
            guard let message = response.data?.message else { return }
            self?.saveMessage(message: message)
        }.store(in: &subscriptions)
    }
    
    func showDeleteConfirmDialog(message: Message) {
        guard let id = message.id else { return }
        var actions: [AlertViewButton] = [.destructive(title: .getStringFor(.deleteForMe))]
        if message.fromUserId == myUserId {
            actions.append(.destructive(title: .getStringFor(.deleteForEveryone)))
        }
        getAppCoordinator()?
            .showAlert(actions: actions)
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.deleteMessage(id: id, target: .user)
                case 1:
                    self?.deleteMessage(id: id, target: .all)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func deleteMessage(id: Int64, target: DeleteMessageTarget) {
        repository.deleteMessage(messageId: id, target: target).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let message = response.data?.message else { return }
            self?.saveMessage(message: message)
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    func trySendMessage(text: String) {
        let uuid = UUID().uuidString
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: myUserId,
                              roomId: room.id,
                              type: .text,
                              body: MessageBody(text: text, file: nil, thumb: nil, type: nil, subject: nil, subjectId: nil, objects: nil, objectIds: nil),
                              replyId: selectedMessageToReplyPublisher.value?.id,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { _ in
            
        } receiveValue: { [weak self] messages in
            let body = RequestMessageBody(text: message.body?.text,
                                          fileId: nil,
                                          thumbId: nil)
            self?.selectedMessageToReplyPublisher.send(nil)
            self?.sendMessage(body: body, localId: uuid, type: .text, replyId: message.replyId)
        }.store(in: &subscriptions)
    }
    
    
    func sendMessage(body: RequestMessageBody, localId: String, type: MessageType, replyId: Int64?) {
        repository.sendMessage(body: body, type: type, roomId: room.id, localId: localId, replyId: replyId).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                print("send text message error: ", error)
            }
        } receiveValue: { [weak self] response in
//            print("SendMessage response: ", response)
            guard let self,
                  let message = response.data?.message
            else { return }
            self.saveMessage(message: message)
        }.store(in: &self.subscriptions)
    }
    
    func saveMessage(message: Message) {
        repository.saveMessages([message]).sink { _ in
            
        } receiveValue: { _ in
            
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    func getUser(for id: Int64) -> User? {
        return room.users.first(where: { roomUser in
            roomUser.userId == id
        })?.user
    }
}

extension CurrentChatViewModel {
    func sendSeenStatus() {
        repository.sendSeenStatus(roomId: room.id)
        repository.removeNotificationsWith(roomId: room.id)
    }
}

// MARK: - Upload handling

extension CurrentChatViewModel {
    func addToUploads(_ up: UploadProgess) {
        uploadsInProgress[up.uuid] = up.percentUploaded
        uploadProgressPublisher.send(up.uuid)
    }
}

// MARK: - video handling

extension CurrentChatViewModel {
    func saveTempVideoMessage(uuid: String, width: CGFloat, height: CGFloat) {
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: myUserId, roomId: room.id, type: .video,
                              body: MessageBody(text: nil, file: nil,
                                                thumb: FileData(id: nil, fileName: nil,
                                                                mimeType: nil, size: nil,
                                                                metaData: MetaData(width: width.roundedInt64, height: height.roundedInt64, duration: 0)), type: nil, subject: nil, subjectId: nil, objects: nil, objectIds: nil),
                              replyId: nil, localId: uuid)
        saveMessage(message: message)
    }
    
    func compressAndSendVideo(url: URL, uuid: String) async {
        // generate jpg thumbnail, save it to uuidthumb.jpg
        guard let thumbnail = url.videoThumbnail(),
              let jpegData = thumbnail.jpegData(compressionQuality: 1)
        else { return }
        let thumbUrl = repository.saveDataToFile(jpegData, name: "\(uuid)thumb.jpg")
        
        // save temp message and start spinning
        compressionsInProgress.insert(uuid)
        saveTempVideoMessage(uuid: uuid, width: thumbnail.size.width, height: thumbnail.size.height)
        
        // compress and export as uuid.mp4, get metadata
        guard let mp4Url = await url.compressAsMP4(name: uuid),
              let videoMetadata = await AVAsset(url: mp4Url).videoMetadata()
        else { return }
        compressionsInProgress.remove(uuid)

        // send file (will show upload progress)
        sendFile(file: SelectedFile(fileType: .video,
                                    name: "moguce bitno za doc ce bit",
                                    fileUrl: mp4Url,
                                    thumbUrl: thumbUrl,
                                    thumbMetadata: thumbUrl?.imageMetaData(),
                                    metaData: videoMetadata,
                                    mimeType: "video/mp4",
                                    localId: uuid))
    }
}

// MARK: - files handling
extension CurrentChatViewModel {
    func openFile(message: Message) {
        guard let url = message.body?.file?.id?.fullFilePathFromId() else { return }
        if message.body?.file?.mimeType == "application/pdf" {
            getAppCoordinator()?.presentPdfViewer(url: url)
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - sending pictures/video

extension CurrentChatViewModel {
    
    func upload(file: SelectedFile) {
        switch file.fileType {
        case .image, .video:
            guard let thumbURL = file.thumbUrl,
                  let thumbMetadata = file.thumbMetadata
            else { return }
            addToUploads(UploadProgess(uuid: file.localId, percentUploaded: 0.01))
            repository
                .uploadWholeFile(fromUrl: thumbURL, mimeType: "image/*", metaData: thumbMetadata, specificFileName: nil)
                .sink { _ in
                    
                } receiveValue: { [weak self] filea, percent in
                    guard let filea = filea else { return }
                    guard let self else { return }
                    let fileName = file.mimeType == "image/*" ? file.name?.appending(".jpg") : nil
                    self.repository
                        .uploadWholeFile(fromUrl: file.fileUrl, mimeType: file.mimeType, metaData: file.metaData, specificFileName: fileName)
                        .sink { _ in
                            
                        } receiveValue: { [weak self] fileb, percent in
                            guard let self else { return }
                            self.addToUploads(UploadProgess(uuid: file.localId, percentUploaded: percent))
                            guard let fileb = fileb else { return }
                            self.sendMessage(body: RequestMessageBody(text: nil, fileId: fileb.id, thumbId: filea.id), localId: file.localId, type: file.fileType, replyId: nil)
                        }.store(in: &self.subscriptions)
                }.store(in: &subscriptions)
        default:
            addToUploads(UploadProgess(uuid: file.localId, percentUploaded: 0.01))
            repository
                .uploadWholeFile(fromUrl: file.fileUrl,
                                 mimeType: file.mimeType,
                                 metaData: file.metaData,
                                 specificFileName: file.name)
                .sink { _ in
                    
                } receiveValue: { [weak self] filea, percent in
                    self?.addToUploads(UploadProgess(uuid: file.localId, percentUploaded: percent))
                    self?.sendMessage(body: RequestMessageBody(text: nil, fileId: filea?.id, thumbId: nil),
                                      localId: file.localId,
                                      type: .file,
                                      replyId: nil)
                }.store(in: &subscriptions)
        }
        
    }
    
    func sendFile(file: SelectedFile) {
        let uuid = file.localId
        
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: myUserId,
                              roomId: room.id,
                              type: file.fileType,
                              body: MessageBody(text: nil,
                                                file: FileData(id: nil,
                                                               fileName: file.name,
                                                               mimeType: file.mimeType,
                                                               size: nil,
                                                               metaData: file.metaData),
                                                thumb: FileData(id: nil,
                                                                fileName: nil,
                                                                mimeType: nil,
                                                                size: nil,
                                                                metaData: file.thumbMetadata), type: nil, subject: nil, subjectId: nil, objects: nil, objectIds: nil),
                              replyId: nil,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { _ in
            
        } receiveValue: { [weak self] messages in
            self?.upload(file: file)
        }.store(in: &subscriptions)
    }
    
    func sendResized(resizedImage: UIImage) {
        let uuid = UUID().uuidString
        guard let jpgData = resizedImage.jpegData(compressionQuality: 1),
              let fileURL = repository.saveDataToFile(jpgData, name: uuid),
              let thumbData = fileURL.downsample(isForThumbnail: true)?.jpegData(compressionQuality: 1),
              let thumbURL = repository.saveDataToFile(thumbData, name: "\(uuid)thumb"),
              let fileMetadata = fileURL.imageMetaData(),
              let thumbMetadata = thumbURL.imageMetaData()
        else { return }
        
        let file = SelectedFile(fileType: .image, name: uuid,
                                fileUrl: fileURL, thumbUrl: thumbURL,
                                thumbMetadata: thumbMetadata, metaData: fileMetadata,
                                mimeType: "image/*", localId: uuid)
        sendFile(file: file)
    }
    
    func sendMultimedia(_ results: [PHPickerResult]) {
        for result in results {
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                    guard let url = url,
                          let downsampledImage = url.downsample()
                    else { return }
                    self?.sendResized(resizedImage: downsampledImage)
                }
            }
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                    // this url is valid only here, copy file and pass it forward
                    let uuid = UUID().uuidString
                    guard let fileSize = try? url?.resourceValues(forKeys: [.fileSizeKey])
                        .fileSize, fileSize < 256000000
                    else {
                        _ = self?.getAppCoordinator()?.showAlert(title: "Large file", message: "Some files are larger than 256 MB and will not be sent.", style: .alert, actions: [.regular(title: "Ok")])
                        return }
                    guard let url,
                    let fileUrl = self?.repository.copyFile(from: url, name: uuid+"original")
                    else { return }
                    
                    Task { [weak self] in
                        await self?.compressAndSendVideo(url: fileUrl, uuid: uuid)
                    }
                }
            }
        }
    }
    
    func sendDocuments(urls: [URL]) {
        for url in urls {
            let uuid = UUID().uuidString
            let fileName = url.lastPathComponent
            guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey]) else { return }
            let mimeType = resourceValues.contentType?.preferredMIMEType ?? "application/octet-stream"
            
            guard let fileSize = resourceValues.fileSize, fileSize < 128000000
            else {
                _ = getAppCoordinator()?.showAlert(title: "Large file", message: "Some files are larger than 128 MB and will not be sent.", style: .alert, actions: [.regular(title: "Ok")])
                return
            }
            let file = SelectedFile(fileType: .file,
                                    name: fileName,
                                    fileUrl: url,
                                    thumbUrl: nil,
                                    thumbMetadata: nil,
                                    metaData: MetaData(width: 0, height: 0, duration: 0),
                                    mimeType: mimeType,
                                    localId: uuid)
            sendFile(file: file)
        }
    }
    
    func sendCameraImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1),
              let resizedImage = repository.saveDataToFile(data, name: "tempFile")?.downsample()
        else { return }
        sendResized(resizedImage: resizedImage)
    }
    
    
}

// MARK: - Reactions

extension CurrentChatViewModel {
    func sendReaction(reaction: String, messageId: Int64) {
        repository.sendReaction(messageId: messageId, reaction: reaction)
            .sink { _ in
            } receiveValue: { [weak self] response in
                guard let records = response.data?.messageRecords else { return }
                _ = self?.repository.saveMessageRecords(records)
            }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    func getMessage(for indexPath: IndexPath) -> Message? {
        guard let entity = messagesFRC?.object(at: indexPath) else { return nil }
        var fileData: FileData?
        var thumbData: FileData?
        
        if let localId = entity.localId,
        let b = filesFRC?.fetchedObjects?.first(where: { $0.localId == localId }){
            fileData = FileData(entity: b)
        }
        
        if let localId = entity.localId?.appending("thumb"),
           let b = filesFRC?.fetchedObjects?.first(where: { $0.localId == localId })
        {
            thumbData = FileData(entity: b)
        }
        
        let reactionRecords = getReactionRecords(messageId: entity.id)

        return Message(messageEntity: entity,
                       fileData: fileData,
                       thumbData: thumbData,
                       records: reactionRecords)
    }
    
    func getReactionRecords(messageId: String?) -> [MessageRecord] {
        guard let messageId, let number = Int64(messageId) else { return []}
        return reactionsFRC?.fetchedObjects?.filter({ $0.messageId == number }).compactMap({ MessageRecord(messageRecordEntity: $0)
        }) ?? []
    }
    
    func getIndexPathFor(localId: String) -> IndexPath? {
        guard let entity = messagesFRC?.fetchedObjects?.first(where: { $0.localId == localId })
        else { return nil }
        return messagesFRC?.indexPath(forObject: entity)
    }
    
    func getIndexPathFor(messageId id: Int64) -> IndexPath? {
        guard let entity = messagesFRC?.fetchedObjects?.first(where: { $0.id == "\(id)" })
        else { return nil }
        return messagesFRC?.indexPath(forObject: entity)
    }
}

// FRC stuff

extension CurrentChatViewModel {
    func loadMore() {
//        frc?.fetchRequest.fetchLimit = (frc?.fetchRequest.fetchLimit ?? 0) + 15
//        frc?.fetchRequest.fetchOffset = (frc?.fetchRequest.fetchOffset ?? 10) - 15
//        try? frc?.performFetch()
        
        // this to refresh add to VC
        //            let oldTableViewHeight = currentChatView.messagesTableView.contentSize.height;
        //
        //            // Reload your table view with your new messages
        //            viewModel.loadMore()
        //            currentChatView.messagesTableView.reloadData()
        //
        //            // Put your scroll position to where it was before
        //            let newTableViewHeight = currentChatView.messagesTableView.contentSize.height;
        //            currentChatView.messagesTableView.contentOffset = CGPointMake(0, newTableViewHeight - oldTableViewHeight);
    }
    
    private func fetchRequest() -> NSFetchRequest<MessageEntity> {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "roomId == %d", room.id)
        return fetchRequest
    }
    
    
    // TODO: - check if this can be more optimized
//    private func getCountOfAllMessages() {
//        let fetchRequest = MessageEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "roomId == %d", room.id)
//        fetchRequest.propertiesToFetch = [#keyPath(MessageEntity.createdAt)]
//        countOfAllMessages = (try? repository.getMainContext().count(for: fetchRequest)) ?? 0
//    }

//    func getFetchOffset(_ direction: PagionationDirection) -> Int {
//        switch direction {
//        case .up:
//            let newOff = currentOffset - fetchLimit
//            self.currentOffset = newOff < 0 ? 0 : newOff
//            return currentOffset
//        case .down:
//            let newOf = currentOffset + fetchLimit
//            self.currentOffset = newOf >= countOfAllMessages ? currentOffset : newOf
//            return currentOffset
//        case .initial:
//            let newOffset = countOfAllMessages - fetchLimit
//            self.currentOffset = newOffset < 0 ? 0 : newOffset
//            return currentOffset
//        }
//    }
    
    
    func setFetch(_ direction: PagionationDirection) {
        let fetchRequest = fetchRequest()
//        fetchRequest.fetchLimit = fetchLimit * 2
//        fetchRequest.fetchOffset = getFetchOffset(direction)
        fetchRequest.fetchLimit = 0
        fetchRequest.fetchOffset = 0
        self.messagesFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                              sectionNameKeyPath: "sectionName",
                                              cacheName: nil)
        do {
            try self.messagesFRC?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
    }
    
    func getNameForSection(section: Int) -> String? {
        guard let sections = messagesFRC?.sections else { return nil }
        var name = sections[section].name
        if let time = (sections[section].objects?.first as? MessageEntity)?.createdAt {
            name.append(", ")
            name.append(time.convert(to: .HHmm))
        }
        return name
    }
    
    func isPreviousCellSameSender(for indexPath: IndexPath) -> Bool {
        let previousRow = indexPath.row - 1
        if previousRow >= 0 {
            let currentMessageEntity  = messagesFRC?.object(at: indexPath)
            let previousMessageEntity = messagesFRC?.object(at: IndexPath(row: previousRow,
                                                                  section: indexPath.section))
            return currentMessageEntity?.fromUserId == previousMessageEntity?.fromUserId
        }
        return false
    }
    
    func isNextCellSameSender(for indexPath: IndexPath) -> Bool {
        guard let sections = messagesFRC?.sections else { return true }
        let maxRowsIndex = sections[indexPath.section].numberOfObjects - 1
        let nextRow = indexPath.row + 1
        if nextRow <= maxRowsIndex {
            let currentMessageEntity  = messagesFRC?.object(at: indexPath)
            let nextMessageEntity = messagesFRC?.object(at: IndexPath(row: nextRow,
                                                              section: indexPath.section))
            return currentMessageEntity?.fromUserId == nextMessageEntity?.fromUserId
        }
        return false
    }
}
