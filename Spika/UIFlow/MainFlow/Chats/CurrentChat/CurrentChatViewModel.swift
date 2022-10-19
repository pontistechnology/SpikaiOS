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

class CurrentChatViewModel: BaseViewModel {
    
    let friendUser: User?
    var room: Room?
    let roomPublisher = PassthroughSubject<Room, Error>()
    let selectedFiles = CurrentValueSubject<[SelectedFile], Never>([])
    let uploadProgressPublisher = PassthroughSubject<(Int, CGFloat), Never>()
    
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
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
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
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
                // TODO: present dialog and return? publish error
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("creating room response: ", response)
            if let errorMessage = response.message {
                PopUpManager.shared.presentAlert(with: (title: "Error", message: errorMessage), orientation: .horizontal, closures: [("Ok", {
                    self.getAppCoordinator()?.popTopViewController()
                })])
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
    
    func trySendMessage(text: String) {
        guard let room = self.room else { return }
        sendSelectedFiles(files: selectedFiles.value)
        print("ROOM: ", room)
        let uuid = UUID().uuidString
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: repository.getMyUserId(),
                              roomId: room.id, type: .text,
                              body: MessageBody(text: text, file: nil, fileId: nil, thumbId: nil), localId: uuid)
        
        repository.saveMessages([message]).sink { c in
            
        } receiveValue: { [weak self] messages in
            guard let self = self,
                  let body = message.body
            else { return }
            self.sendMessage(body: body, localId: uuid, type: .text)
        }.store(in: &subscriptions)
    }
    
    
    func sendMessage(body: MessageBody, localId: String, type: MessageType) {
        guard let room = self.room else { return }
        
        self.repository.sendMessage(body: body, type: type, roomId: room.id, localId: localId).sink { [weak self] completion in
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

// MARK: Image
extension CurrentChatViewModel {
    private func sendImage(data: Data) {
        repository.uploadWholeFile(data: data).sink { c in
            print(c)
        } receiveValue: { [weak self] (file, uploadPercent) in
            guard let self = self else { return }
            print("PERCENT: ", uploadPercent, ", file: ", file)
            
            if let file = file {
                print("UPLOADANO : ", file)
                self.sendMessage(body: MessageBody(text: nil, file: nil, fileId: file.id, thumbId: nil), localId: UUID().uuidString, type: .image)
            }
        }.store(in: &subscriptions)
    }
    
    func sendSelectedFiles(files: [SelectedFile]) {
        files.forEach { selectedFile in
            if selectedFile.fileType == .image {
                repository.uploadWholeFile(fromUrl: selectedFile.fileUrl).sink { c in
                    
                } receiveValue: { [weak self] (file, uploadPercent) in
                    guard let self = self else { return }
                    if let index = files.firstIndex(where: { sf in
                        sf.fileUrl == selectedFile.fileUrl
                    }) {
                        self.uploadProgressPublisher.send((index, uploadPercent))
                    }
                    
                    print("NOVA: ", uploadPercent)
                    if let file = file {
                        print("UPLOADANO : ", file)
//                        self.selectedFiles.value.removeAll { sf in
//                            sf.fileUrl == selectedFile.fileUrl
//                        }
                        self.sendMessage(body: MessageBody(text: nil, file: nil, fileId: file.id, thumbId: file.id), localId: UUID().uuidString, type: .image)
                    }
                }.store(in: &subscriptions)
            } else {
                repository.uploadWholeFile(fromUrl: selectedFile.fileUrl).sink { c in
                    
                } receiveValue: { [weak self] (file, uploadPercent) in
                    guard let self = self else { return }
                    if let index = files.firstIndex(where: { sf in
                        sf.fileUrl == selectedFile.fileUrl
                    }) {
                        self.uploadProgressPublisher.send((index, uploadPercent))
                    }
                    
                    if let file = file {
                        self.sendMessage(body: MessageBody(text: nil, file: nil, fileId: file.id, thumbId: nil), localId: UUID().uuidString, type: .file)
                    }
                }.store(in: &subscriptions)

            }
        }
    }
}

extension CurrentChatViewModel {
    func getUser(for id: Int64) -> User? {
        return room?.users.first(where: { roomUser in
            roomUser.userId == id
        })?.user
    }
}
