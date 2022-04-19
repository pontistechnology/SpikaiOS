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
    
    let friendUser: LocalUser
    var roomEntityID: NSManagedObjectID?
    let sort = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)
    lazy var coreDataFetchedResults = CoreDataFetchedResults(ofType: MessageEntity.self,
                                                             entityName: "MessageEntity",
                                                             sortDescriptors: [sort],
                                                             managedContext: repository.getMainContext(),
                                                             delegate: nil)
    let tableViewShouldReload = PassthroughSubject<Bool, Never>()
    
    init(repository: Repository, coordinator: Coordinator, friendUser: LocalUser) {
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
        } receiveValue: { [weak self] roomEntityID in
            guard let self = self else { return }
            self.roomEntityID = roomEntityID
            self.setFetch()
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
            guard let self = self else { return }
            switch completion {
                
            case .finished:
                print("saved to local DB")
            case .failure(_):
                print("saving to local DB failed")
            }
        } receiveValue: { [weak self] roomEntityID in
            guard let self = self else { return }
            self.roomEntityID = roomEntityID
            self.setFetch()
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
                // TODO: present dialog and return?
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("creating room response: ", response)
            guard let room = response.data?.room else { return }
            self.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
    
    func setFetch() {
        DispatchQueue.main.async {
            print("setFetch thread:", Thread.current)
            let mainMOC = self.repository.getMainContext()
            guard let roomEntityID = self.roomEntityID,
                  let roomEntity = (mainMOC.object(with: roomEntityID) as? RoomEntity)
            else { return }
            
            let predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(MessageEntity.roomId), "\(roomEntity.id)")
            self.coreDataFetchedResults.controller.fetchRequest.predicate = predicate
            self.coreDataFetchedResults.performFetch { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.tableViewShouldReload.send(true)
                case .failure(_):
                    break
                }
            }
        }
    }
}

extension CurrentPrivateChatViewModel {
    
    func trySendMessage(text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let roomEntityID = self.roomEntityID,
                  let roomEntity = (self.repository.getMainContext().object(with: roomEntityID) as? RoomEntity)
            else { return }
        
            let mesa = MessageEntity(message: Message(text: text,
                                                      myId: self.repository.getMyUserId(),
                                                      roomId: Int(roomEntity.id)),
                                     context: self.repository.getMainContext())
            try! self.repository.getMainContext().save()
            self.sendMessage(messageEntity: mesa)
        }
    }
    
    func sendMessage(messageEntity: MessageEntity) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self,
                  let roomEntityID = self.roomEntityID,
                  let roomEntity = (self.repository.getMainContext().object(with: roomEntityID) as? RoomEntity),
                  let text = messageEntity.bodyText
            else { return }
            
            self.repository.sendTextMessage(message: MessageBody(text: text), roomId: Int(roomEntity.id)).sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                    
                case .finished:
                    print("finished")
                case .failure(_):
                    print("failure")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                print("SendMessage response: ", response)
                DispatchQueue.main.async {
                    messageEntity.seenCount = 0 // TODO: change logic and order, change Message body
                    try! self.repository.getMainContext().save()
                }
                
    //            guard let message = response.data?.message else { return }
                
            }.store(in: &self.subscriptions)
        }
    }
}
