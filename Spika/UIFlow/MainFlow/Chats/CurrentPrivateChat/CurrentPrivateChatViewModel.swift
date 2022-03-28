//
//  CurrentPrivateChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine
import CoreData

class CurrentPrivateChatViewModel: BaseViewModel {
    
    let friendUser: LocalUser
    var room: Room?
    
    let sort = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)
    lazy var coreDataFetchedResults = CoreDataFetchedResults(ofType: MessageEntity.self, entityName: "MessageEntity", sortDescriptors: [sort], managedContext: CoreDataManager.shared.managedContext, delegate: nil)
    
    init(repository: Repository, coordinator: Coordinator, friendUser: LocalUser) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
    }

    // Check room first then prooceed
    func checkRoom()  {
        networkRequestState.send(.started())
        repository.checkRoom(forUserId: friendUser.id).sink { completion in
            switch completion {
            case .finished:
                print("check finished")
            case .failure(let error):
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
                self.networkRequestState.send(.finished)
            }
        } receiveValue: { response in
            
            if let room = response.data?.room {
                self.room = room
                self.networkRequestState.send(.finished)
//                self.setFetch()
            } else {
                self.createRoom(userId: self.friendUser.id)
            }
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int) {
        repository.createRoom(userId: userId).sink { completion in
            self.networkRequestState.send(.finished)
            
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                PopUpManager.shared.presentAlert(errorMessage: error.localizedDescription)
            }
        } receiveValue: { response in
            // TODO: set room
            print("creating room response: ", response)
        }.store(in: &subscriptions)
    }
    


    func setFetch() {
//        guard let room = room else {
//            return
//        }
        let predicate = NSPredicate(format: "%K != %@",
                                    #keyPath(MessageEntity.bodyText), "miki")
        coreDataFetchedResults.controller.fetchRequest.predicate = predicate
        coreDataFetchedResults.performFetch()
    }
}

// test sending states
extension CurrentPrivateChatViewModel {
    
    func trySendMessage(text: String) {
        let mesa = MessageEntity(message: Message(text: text))
        CoreDataManager.shared.saveContext()
        sendMessage3(messageEntity: mesa)
    }
    
    func sendMessage3(messageEntity: MessageEntity) {
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
            print("SendMessage3 response: ", response)
            messageEntity.seenCount = 0
            CoreDataManager.shared.saveContext()
            guard let message = response.data?.message else { return }
            
        }.store(in: &subscriptions)
    }
}
