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
    
    let friendUser: User?
    var room: Room?
    let roomPublisher = PassthroughSubject<Room, Error>()
    let uploadProgressPublisher = PassthroughSubject<(localId: String, percentUploaded: CGFloat), Never>()
    
    init(repository: Repository, coordinator: Coordinator, friendUser: User) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
    }
    
    init(repository: Repository, coordinator: Coordinator, room: Room) {
        self.room = room
        
        let roomUsers = room.users
        self.friendUser = room.getFriendUserInPrivateRoom(myUserId: repository.getMyUserId())
        super.init(repository: repository, coordinator: coordinator)
    }
}

// MARK: - Navigation
extension CurrentChatViewModel {
    func popTopViewController() {
        getAppCoordinator()?.popTopViewController()
    }
    
    func presentMessageDetails(records: [MessageRecord]) {
        guard let roomUsers = room?.users else {
            return
        }
        let users = roomUsers.compactMap { roomUser in
            roomUser.user
        }
        getAppCoordinator()?.presentMessageDetails(users: users, records: records)
    }
    
    func presentMoreActions() -> PassthroughSubject<MoreActions, Never>? {
        return getAppCoordinator()?.presentMoreActionsSheet()
    }
    
    func playVideo(message: Message) {
        guard let url = message.body?.file?.id?.fullFilePathFromId(),
              let mimeType = message.body?.file?.mimeType
        else { return }
        let asset = AVURLAsset(url: url, mimeType: mimeType)
        getAppCoordinator()?.presentAVVideoController(asset: asset)
    }
    
    func showImage(link: URL) {
        getAppCoordinator()?.presentImageViewer(link: link)
    }
}

extension CurrentChatViewModel {
    
    func checkLocalRoom() {
        if let room = room {
            roomPublisher.send(room)
        } else if let friendUser = friendUser {
            repository.checkLocalRoom(forUserId: friendUser.id).sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    print("no local room")
                    self.checkOnlineRoom()
                }
            } receiveValue: { [weak self] room in
                guard let self = self else { return }
                self.room = room
                self.roomPublisher.send(room)
            }.store(in: &subscriptions)
        }
    }
    
    func checkOnlineRoom()  {
        guard let friendUser = friendUser else { return }
        networkRequestState.send(.started())
        
        repository.checkOnlineRoom(forUserId: friendUser.id).sink { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                self.showError(error.localizedDescription)
                self.networkRequestState.send(.finished)
                // TODO: publish error
            }
        } receiveValue: { [weak self] response in
            
            guard let self = self else { return }
            
            if let room = response.data?.room {
                print("There is online room.")
                self.saveLocalRoom(room: room)
                self.networkRequestState.send(.finished)
            } else {
                print("There is no online room, creating started...")
                self.createRoom(userId: friendUser.id)
            }
        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveLocalRooms(rooms: [room]).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("saved to local DB")
            case .failure(_):
                print("saving to local DB failed")
            }
        } receiveValue: { [weak self] rooms in
            guard let self = self,
                  let room = rooms.first
            else { return }
            self.room = room
            self.roomPublisher.send(room)
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int64) {
        networkRequestState.send(.started())
        repository.createOnlineRoom(userId: userId).sink { [weak self] completion in
            guard let self = self else { return }
            self.networkRequestState.send(.finished)
            
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                self.showError(error.localizedDescription)
                // TODO: present dialog and return? publish error
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("creating room response: ", response)
            if let errorMessage = response.message {
//                PopUpManager.shared.presentAlert(with: (title: "Error", message: errorMessage), orientation: .horizontal, closures: [("Ok", {
//                    self.getAppCoordinator()?.popTopViewController()
//                })]) // TODO: - check
            }
            guard let room = response.data?.room else { return }
            self.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
    
    func roomVisited(roomId: Int64) {
        repository.roomVisited(roomId: roomId)
    }
}

extension CurrentChatViewModel {
    func trySendMessage(text: String, replyId: Int64?) {
        guard let room = self.room else { return }
        print("ROOM: ", room)
        let uuid = UUID().uuidString
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: .text,
                              body: MessageBody(text: text, file: nil, thumb: nil),
                              replyId: replyId,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { c in
            
        } receiveValue: { [weak self] messages in
            let body = RequestMessageBody(text: message.body?.text, fileId: message.body?.file?.id, thumbId: message.body?.thumb?.id)
            self?.sendMessage(body: body, localId: uuid, type: .text, replyId: message.replyId)
        }.store(in: &subscriptions)
    }
    
    
    func sendMessage(body: RequestMessageBody, localId: String, type: MessageType, replyId: Int64?) {
        guard let room = self.room else { return }
        
        self.repository.sendMessage(body: body, type: type, roomId: room.id, localId: localId, replyId: replyId).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("finished")
            case let .failure(error):
                print("send text message error: ", error)
            }
        } receiveValue: { [weak self] response in
            print("SendMessage response: ", response)
            guard let self = self,
                  let message = response.data?.message
            else { return }
            self.saveMessage(message: message, room: room)
        }.store(in: &self.subscriptions)
    }
    
    func saveMessage(message: Message, room: Room) {
        repository.saveMessages([message]).sink { c in
            print(c)
        } receiveValue: { _ in
            
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    func getUser(for id: Int64) -> User? {
        return room?.users.first(where: { roomUser in
            roomUser.userId == id
        })?.user
    }
}

extension CurrentChatViewModel {
    func sendSeenStatus() {
        guard let roomId = room?.id else { return }
        repository.sendSeenStatus(roomId: roomId).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let messageRecords = response.data?.messageRecords else { return }
            self?.repository.saveMessageRecords(messageRecords)
        }.store(in: &subscriptions)
    }
}

// MARK: - sending pictures/video

extension CurrentChatViewModel {
    
    func upload(file: SelectedFile, localId: String) {
        switch file.fileType {
        case .image, .video:
            guard let data = file.thumbnail?.jpegData(compressionQuality: 1) else { return }
            repository
                .uploadAllChunks(fromUrl: file.fileUrl)
                .combineLatest(repository.uploadAllChunks(fromData: data))
                .sink { c in
                } receiveValue: { [weak self] filePublisher, thumbPublisher in
                    self?.uploadProgressPublisher.send((localId: localId, percentUploaded: filePublisher.percentUploaded))
                    guard let self = self,
                        let thumbChunksData = thumbPublisher.chunksDataToVerify,
                        let fileChunksData = filePublisher.chunksDataToVerify
                    else { return }
                    
                    self.verifyUpload(chunksDataToVerify: thumbChunksData,
                                      mimeType: "image/*",
                                      metaData: MetaData(width: 72, height: 72, duration: 0))
                        .combineLatest(self.verifyUpload(chunksDataToVerify: fileChunksData,
                                                         mimeType: file.mimeType,
                                                         metaData: file.metaData))
                        .sink(receiveValue: { [weak self] uploadedThumb, uploadedFile in
                            self?.sendMessage(body: RequestMessageBody(text: nil,
                                                                       fileId: uploadedFile.id,
                                                                       thumbId: uploadedThumb.id),
                                              localId: localId,
                                              type: file.fileType,
                                              replyId: nil)
                        }).store(in: &self.subscriptions)
                }.store(in: &subscriptions)
        default:
            repository
                .uploadAllChunks(fromUrl: file.fileUrl)
                .sink { c in
                    
                } receiveValue: { [weak self] filePublisher in
                    guard let self = self else { return }
                    if let dd = filePublisher.chunksDataToVerify {
                        self.verifyUpload(chunksDataToVerify: dd, mimeType: file.mimeType, metaData: file.metaData)
                            .sink(receiveValue: { [weak self] file in
                                guard let self = self else { return }
                                self.sendMessage(body: RequestMessageBody(text: nil, fileId: file.id, thumbId: nil), localId: localId, type: .file, replyId: nil)
                            }).store(in: &self.subscriptions)
                    }
                }.store(in: &subscriptions)
        }
        
    }
    
    func verifyUpload(chunksDataToVerify: ChunksDataToVerify, mimeType: String, metaData: MetaData) -> PassthroughSubject<File, Never> {
        let publisher = PassthroughSubject<File, Never>()
        
        repository
            .verifyUpload(total: chunksDataToVerify.totalChunks,
                                size: chunksDataToVerify.size,
                                mimeType: mimeType,
                                fileName: chunksDataToVerify.fileName,
                                clientId: chunksDataToVerify.clientId,
                                fileHash: chunksDataToVerify.fileHash,
                                type: "smt",
                                relationId: 1,
                                metaData: metaData)
            .compactMap { $0.data?.file }
            .sink { c in
                
            } receiveValue: { file in
                publisher.send(file)
            }.store(in: &subscriptions)
        return publisher
    }
    
    func sendImage(file: SelectedFile) {
        guard let room = room else { return }
        let uuid = UUID().uuidString
        
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: .image,
                              body: MessageBody(text: nil,
                                                file: nil,
                                                thumb: nil),
                              replyId: nil,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { c in
            
        } receiveValue: { [weak self] messages in
            self?.upload(file: file, localId: uuid)
        }.store(in: &subscriptions)
    }
    
    func sendUploadedFiles() {
        
    }
    
    func sendMultimedia(_ results: [PHPickerResult]) {
        for result in results {
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    guard let url = url,
                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                          url.copyFileFromURL(to: targetURL) == true
                    else { return }
                    let thumbnail = targetURL.imageThumbnail()
                    let metaData = targetURL.imageMetaData()
                    let file = SelectedFile(fileType: .image, name: nil,
                                            fileUrl: targetURL, thumbnail: thumbnail, metaData: metaData,
                                            mimeType: "image/*")
                    self?.sendImage(file: file)
                }
            }
            
//            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
//                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//                    guard let url = url,
//                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
//                          url.copyFileFromURL(to: targetURL) == true
//                    else { return }
//                    let thumb = url.videoThumbnail()
//                    let file  = SelectedFile(fileType: .movie, name: "video",
//                                             fileUrl: targetURL, thumbnail: thumb)
////                    self?.viewModel.selectedFiles.value.append(file)
//                }
//            }
        }
    }
}
