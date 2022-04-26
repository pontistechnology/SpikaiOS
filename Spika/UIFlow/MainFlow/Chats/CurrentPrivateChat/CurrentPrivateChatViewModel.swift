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
            if let errorMessage = response.message {
                PopUpManager.shared.presentAlert(with: (title: "Error", message: errorMessage), orientation: .horizontal, closures: [("Ok", {
                    self.getAppCoordinator()?.popTopViewController()
                })])
            }
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
        print("ROOM: ", room)
        let uuid = UUID().uuidString
        let message = Message(createdAt: Int(Date().timeIntervalSince1970) * 1000,
                              fromUserId: repository.getMyUserId(),
                              roomId: room.id, type: .text,
                              body: MessageBody(text: text), localId: uuid)
        
        repository.saveMessage(message: message).sink { completion in
            print("save message c: ", completion)
        } receiveValue: { [weak self] message in
            guard let self = self else { return }
            guard let body = message.body else {
                print("GUARD trySendMessage body missing")
                return }
            self.sendMessage(body: body, localId: uuid)
        }.store(in: &subscriptions)
    }
    
    
    func sendMessage(body: MessageBody, localId: String) {
        guard let room = self.room else { return }
        
        self.repository.sendTextMessage(body: body, roomId: room.id, localId: localId).sink { [weak self] completion in
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
            self.saveMessage(message: message)
        }.store(in: &self.subscriptions)
    }
    
    func saveMessage(message: Message) {
        repository.saveMessage(message: message).sink { c in
            print(c)
        } receiveValue: { _ in
            
        }.store(in: &subscriptions)
    }
        
    func popTopViewController() {
        getAppCoordinator()?.popTopViewController()
    }
}
