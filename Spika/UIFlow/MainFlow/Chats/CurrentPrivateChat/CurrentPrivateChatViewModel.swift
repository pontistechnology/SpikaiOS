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
    var room: Room?
    let sort = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)
    lazy var coreDataFetchedResults = CoreDataFetchedResults(ofType: MessageEntity.self, entityName: "MessageEntity", sortDescriptors: [sort], managedContext: CoreDataManager.shared.managedContext, delegate: nil)
    let tableViewShouldReload = PassthroughSubject<Bool, Never>()
    
    init(repository: Repository, coordinator: Coordinator, friendUser: LocalUser) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
    }
}

extension CurrentPrivateChatViewModel {
    
    func checkLocalRoom() {
        repository.checkPrivateLocalRoom(forId: friendUser.id).sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(_):
                print("no local room")
                self.checkRoom()
                break
            }
        } receiveValue: { room in
            self.room = room
            self.setFetch()
        }.store(in: &subscriptions)
    }
    
    func checkRoom()  {
        networkRequestState.send(.started())
        
        repository.checkRoom(forUserId: friendUser.id).sink { completion in
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
                self.networkRequestState.send(.finished)
            }
        } receiveValue: { response in
            
            if let room = response.data?.room {
                self.room = room
                // TODO: save it to DB
                self.networkRequestState.send(.finished)
                self.setFetch()
            } else {
                self.createRoom(userId: self.friendUser.id)
            }
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int) {
        networkRequestState.send(.started())
        repository.createRoom(userId: userId).sink { completion in
            self.networkRequestState.send(.finished)
            
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
                // TODO: present dialog and return?
            }
        } receiveValue: { response in
            print("creating room response: ", response)
            guard let room = response.data?.room else { return }
            // TODO: save it to DB
            self.room = room
            self.setFetch()
        }.store(in: &subscriptions)
    }
    
    func setFetch() {
        guard let room = room else {
            return
        }
        let predicate = NSPredicate(format: "%K != %@",
                                    #keyPath(MessageEntity.bodyText), "miki") // TODO: add id
        coreDataFetchedResults.controller.fetchRequest.predicate = predicate
        coreDataFetchedResults.performFetch { result in
            switch result {
            case .success(_):
                self.tableViewShouldReload.send(true)
            case .failure(_):
                break
            }
        }
    }
}

// test sending states
extension CurrentPrivateChatViewModel {
    
    func trySendMessage(text: String) {
        let mesa = MessageEntity(message: Message(text: text))
        CoreDataManager.shared.saveContext()
        sendMessage(messageEntity: mesa)
    }
    
    func sendMessage(messageEntity: MessageEntity) {
        guard let room = room,
              let text = messageEntity.bodyText
        else { return }
        
        repository.sendTextMessage(message: MessageBody(text: text), roomId: room.id).sink { completion in
            switch completion {
                
            case .finished:
                print("finished")
            case .failure(_):
                print("failure")
            }
        } receiveValue: { response in
            print("SendMessage response: ", response)
            messageEntity.seenCount = 0 // TODO: change logic
            CoreDataManager.shared.saveContext()
            guard let message = response.data?.message else { return }
            
        }.store(in: &subscriptions)
    }
}
