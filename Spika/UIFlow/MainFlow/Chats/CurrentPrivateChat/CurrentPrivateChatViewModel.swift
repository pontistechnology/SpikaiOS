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

class CurrentPrivateChatViewModel: BaseViewModel {
    
    let friendUser: User
    var room: Room?
    let roomPublisher = PassthroughSubject<Room, Error>()
    
    init(repository: Repository, coordinator: Coordinator, friendUser: User) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
    }
}

extension CurrentPrivateChatViewModel {
    
    func checkLocalRoom() {
        repository.checkPrivateLocalRoom(forId: friendUser.id).sink { [weak self] completion in
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
    
    func checkOnlineRoom()  {
        networkRequestState.send(.started())
        
        repository.checkRoom(forUserId: friendUser.id).sink { [weak self] completion in
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
                self.createRoom(userId: self.friendUser.id)
            }
        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveRoom(room: room).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("saved to local DB")
            case .failure(_):
                print("saving to local DB failed")
            }
        } receiveValue: { [weak self] room in
            guard let self = self else { return }
            self.room = room
            self.roomPublisher.send(room)
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int) {
        networkRequestState.send(.started())
        repository.createRoom(userId: userId).sink { [weak self] completion in
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
            guard let room = response.data?.room else { return }
            self.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
    
    func loadMessages() {
        guard let room = room else { return }
        print("u loag messages stiglo: ", room)
        repository.getMessages(forRoomId: room.id).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(_):
                break
            }
        } receiveValue: { [weak self] messages in
            guard let self = self else { return }
        }.store(in: &subscriptions)
    }
}

extension CurrentPrivateChatViewModel {
    
    func trySendMessage(text: String) {
        guard let room = self.room else { return }
        let message = Message(createdAt: Int(Date().timeIntervalSince1970) * 1000,
                              fromUserId: repository.getMyUserId(),
                              roomId: room.id, type: .text,
                              body: MessageBody(text: text))
        
        repository.saveMessage(message: message).sink { completion in
            
        } receiveValue: { [weak self] (message, uuid) in
            guard let self = self else { return }
            var savedMessage = message
            savedMessage.body?.localId = uuid
            guard let body = savedMessage.body else { return }
            self.sendMessage(body: body, localId: uuid)
        }.store(in: &subscriptions)
    }
    
    // TODO: uuid will not be in body?
    func sendMessage(body: MessageBody, localId: String) {
        guard let room = self.room else { return }
        
        self.repository.sendTextMessage(body: body, roomId: room.id).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("finished")
            case .failure(_):
                print("failure")
            }
        } receiveValue: { [weak self] response in
            print("SendMessage response: ", response)
            guard let self = self,
                  let message = response.data?.message,
                  let localId = message.body?.localId
            else { return }
            self.updateMessage(message: message, localId: localId)
        }.store(in: &self.subscriptions)
    }
    
    func updateMessage(message: Message, localId: String) {
        repository.updateLocalMessage(message: message, localId: localId).sink { completion in
            
        } receiveValue: { [weak self] message in
            //TODO: change in array
            guard let self = self else { return }
//            guard let i = self.messages.firstIndex(where: {$0.body?.localId == localId}) else { return }
//            self.messages[i] = message
//            self.tableViewShouldReload.send(true)
        }.store(in: &subscriptions)

    }
}
