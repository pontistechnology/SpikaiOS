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

class CurrentChatViewModel: BaseViewModel {
    
    var frc: NSFetchedResultsController<MessageEntity>?
    var room: Room
    
    var friendUser: User? {
        room.getFriendUserInPrivateRoom(myUserId: getMyUserId())
    }
    
    let uploadProgressPublisher = PassthroughSubject<(percentUploaded: CGFloat, selectedFile: SelectedFile?), Never>()
    
    private let currentNumberOfCompressingVideos = CurrentValueSubject<Int, Never>(0)
    
    let selectedMessageToReplyPublisher = CurrentValueSubject<Message?, Never>(nil)
    let selectedMessageToEditPublisher = CurrentValueSubject<Message?, Never>(nil)
    let numberOfUnreadMessages = CurrentValueSubject<Int, Never>(0)
    
//    let aaaaT = PassthroughSubject<Int, Never>()
    
    init(repository: Repository, coordinator: Coordinator, room: Room) {
        self.room = room
        super.init(repository: repository, coordinator: coordinator)
        setupBindings()
    }
}

// MARK: - Bindings

extension CurrentChatViewModel {
    func setupBindings() {
        currentNumberOfCompressingVideos.sink { [weak self] number in
            if number == 0 {
                self?.getAppCoordinator()?.removeAlert()
            } else {
                self?.getAppCoordinator()?.showAlert(title: "In development still 🤫", message: "Compressing \(number) video(s)", style: .alert, actions: [.destructive(title: "Wait")], cancelText: "Please")
            }
        }.store(in: &subscriptions)
    }
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
        getAppCoordinator()?.presentReactionsSheet(users: users, records: records)
    }
    
    // TODO: add indexpath
    func showMessageActions(_ message: Message) {
        guard !message.deleted else { return }
        getAppCoordinator()?
            .presentMessageActionsSheet(isMyMessage: message.fromUserId == getMyUserId())
            .sink(receiveValue: { [weak self] action in
                guard let self else { return }
                self.getAppCoordinator()?.dismissViewController()
                guard let id = message.id else { return }
                switch action {
                case .reaction(emoji: let emoji):
                    self.sendReaction(reaction: emoji, messageId: id)
                case .reply:
                    self.selectedMessageToReplyPublisher.send(message)
                case .copy:
                    UIPasteboard.general.string = message.body?.text
                    self.showOneSecAlert(type: .copy)
                case .details:
                    let users = self.room.users.compactMap { $0.user }
                    self.getAppCoordinator()?.presentMessageDetails(users: users, message: message)
                case .delete:
                    self.showDeleteConfirmDialog(message: message)
                case .edit:
                    self.selectedMessageToEditPublisher.send(message)
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
        if message.fromUserId == getMyUserId() {
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
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: .text,
                              body: MessageBody(text: text, file: nil, thumb: nil),
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
        self.repository.sendMessage(body: body, type: type, roomId: room.id, localId: localId, replyId: replyId).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("finished")
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

// MARK: - sending pictures/video

extension CurrentChatViewModel {
    
    func upload(file: SelectedFile) {
        switch file.fileType {
        case .image, .video:
            guard let thumbURL = file.thumbUrl,
                  let thumbMetadata = file.thumbMetadata
            else { return }
            uploadProgressPublisher.send((percentUploaded: 0.01, selectedFile: file))
            repository
                .uploadWholeFile(fromUrl: thumbURL, mimeType: "image/*", metaData: thumbMetadata)
                .sink { _ in
                    
                } receiveValue: { [weak self] filea, percent in
                    guard let filea = filea else { return }
                    guard let self else { return }
                    self.repository
                        .uploadWholeFile(fromUrl: file.fileUrl, mimeType: file.mimeType, metaData: file.metaData)
                        .sink { _ in
                            
                        } receiveValue: { [weak self] fileb, percent in
                            guard let self else { return }
                            self.uploadProgressPublisher.send((percentUploaded: percent, selectedFile: file))
                            guard let fileb = fileb else { return }
                            self.sendMessage(body: RequestMessageBody(text: nil, fileId: fileb.id, thumbId: filea.id), localId: file.localId, type: file.fileType, replyId: nil)
                        }.store(in: &self.subscriptions)
                }.store(in: &subscriptions)
        default:
            uploadProgressPublisher.send((percentUploaded: 0.01, selectedFile: nil))
            repository
                .uploadWholeFile(fromUrl: file.fileUrl,
                                 mimeType: file.mimeType,
                                 metaData: file.metaData)
                .sink { _ in
                    
                } receiveValue: { [weak self] filea, percent in
                    self?.uploadProgressPublisher.send((percentUploaded: percent, selectedFile: nil))
                    self?.sendMessage(body: RequestMessageBody(text: nil, fileId: filea?.id, thumbId: nil),
                                      localId: file.localId,
                                      type: file.fileType,
                                      replyId: nil)
                }.store(in: &subscriptions)
        }
        
    }
    
    func sendFile(file: SelectedFile) {
        let uuid = file.localId
        
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: file.fileType,
                              body: MessageBody(text: nil,
                                                file: FileData(id: nil,
                                                               fileName: file.name,
                                                               mimeType: file.mimeType,
                                                               size: file.size,
                                                               metaData: file.metaData),
                                                thumb: FileData(id: nil,
                                                                fileName: nil,
                                                                mimeType: nil,
                                                                size: nil,
                                                                metaData: file.thumbMetadata)),
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
                                mimeType: "image/*", size: nil, localId: uuid)
        sendFile(file: file)
    }
    
    func compressAndSendVideo(url: URL, uuid: String) async {
        do {
            // generate jpg thumbnail, save it to uuidthumb.jpg
            guard let thumbnail = url.videoThumbnail(),
                  let jpegData = thumbnail.jpegData(compressionQuality: 1)
            else { return }
            let thumbUrl = repository.saveDataToFile(jpegData, name: "\(uuid)thumb.jpg")
            
            // compress and export as uuid.mp4, get metadata
            currentNumberOfCompressingVideos.send(currentNumberOfCompressingVideos.value + 1)
            guard let mp4Url = await url.compressAsMP4(name: uuid) else { return }
            currentNumberOfCompressingVideos.send(currentNumberOfCompressingVideos.value - 1)
            let asset = AVAsset(url: mp4Url)
            let duration = try await asset.load(.duration)
            guard let dimensions = try await asset.load(.tracks).first?
                .load(.naturalSize)
            else { return }
            
            // send file
            sendFile(file: SelectedFile(fileType: .video,
                                        name: "mogucenbitno za doc ce bit",
                                        fileUrl: mp4Url,
                                        thumbUrl: thumbUrl,
                                        thumbMetadata: MetaData(width: thumbnail.size.width.roundedInt64,
                                                                height: thumbnail.size.height.roundedInt64,
                                                                duration: 0),
                                        metaData: MetaData(width: dimensions.width.roundedInt64,
                                                           height: dimensions.height.roundedInt64,
                                                           duration: duration.seconds.roundedInt64),
                                        mimeType: "video/mp4",
                                        size: 0,
                                        localId: uuid))
        } catch {
            print("durationelo: ", error)
        }
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
                    // todo: add some check for file size maybe and skip large files
                    // flow: 1. copy file with new name uuidoriginal.originalExtension
                    // flow: 2. compress and convert to uuid.mp4
                    // flow: 3. delete uuidoriginal.originalExtension
                    // flow: 4. send uuid.mp4
                    let uuid = UUID().uuidString
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
        //        for url in urls {
        //            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
        //                  url.copyFileFromURL(to: targetURL) == true,
        //                  let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey]),
        //                  let type = resourceValues.contentType,
        //                  let size = resourceValues.fileSize
        //            else { return }
        //            let fileName = resourceValues.name ?? "unknownName"
        //
        //            print("TYPEE: ", type)
        //            let file = SelectedFile(fileType: .file,
        //                                    name: fileName,
        //                                    fileUrl: targetURL,
        //                                    thumbnail: nil,
        //                                    metaData: MetaData(width: 0, height: 0, duration: 0),
        //                                    mimeType: "\(type)",
        //                                    size: Int64(size))
        //            sendFile(file: file)
        //        }
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
                self?.repository.saveMessageRecords(records)
            }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    
    func getMessage(for indexPath: IndexPath) -> Message? {
        guard let entity = frc?.object(at: indexPath),
              let context = entity.managedObjectContext
        else { return nil }
        let fileData = repository.getFileData(id: entity.bodyFileId, context: context)
        let thumbData = repository.getFileData(id: entity.bodyThumbId, context: context)
        let reactionRecords = repository.getReactionRecords(messageId: entity.id, context: context)

        return Message(messageEntity: entity,
                       fileData: fileData,
                       thumbData: thumbData,
                       records: reactionRecords)
    }
    
    func getIndexPathFor(localId: String) -> IndexPath? {
        guard let entity = frc?.fetchedObjects?.first(where: { $0.localId == localId })
        else { return nil }
        return frc?.indexPath(forObject: entity)
    }
    
    func getIndexPathFor(messageId id: Int64) -> IndexPath? {
        guard let entity = frc?.fetchedObjects?.first(where: { $0.id == "\(id)" })
        else { return nil }
        return frc?.indexPath(forObject: entity)
    }
}

// FRC stuff

extension CurrentChatViewModel {
    func setFetch() {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: true),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "roomId == %d", room.id)
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                              sectionNameKeyPath: "sectionName",
                                              cacheName: nil)
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
    }
    
    func getNameForSection(section: Int) -> String? {
        guard let sections = frc?.sections else { return nil }
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
            let currentMessageEntity  = frc?.object(at: indexPath)
            let previousMessageEntity = frc?.object(at: IndexPath(row: previousRow,
                                                                  section: indexPath.section))
            return currentMessageEntity?.fromUserId == previousMessageEntity?.fromUserId
        }
        return false
    }
    
    func isNextCellSameSender(for indexPath: IndexPath) -> Bool {
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
