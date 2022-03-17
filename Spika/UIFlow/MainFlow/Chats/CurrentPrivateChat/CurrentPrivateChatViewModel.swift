//
//  CurrentPrivateChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine

class CurrentPrivateChatViewModel: BaseViewModel {
    
    let friendUser: LocalUser
    var room: Room?
    let messagesSubject = CurrentValueSubject<[Message], Never>([
        Message(id: 0, fromUserId: 0, fromDeviceId: 0, totalDeviceCount: 0, receivedCount: 0, seenCount: 0, roomId: 0, type: "text", messageBody: MessageBody(text: "this is hardcoded message"), createdAt: 23)
    ])
    
    let allMessagesSubject = CurrentValueSubject<[LocalMessage2], Never>([
        
    ])
    
    func test(){
        getAppCoordinator()?.test()
    }
    
    
    init(repository: Repository, coordinator: Coordinator, friendUser: LocalUser) {
        self.friendUser = friendUser
        var array: [Message] = []
        for i in 0...100000 {
            array.append(Message(id: 0, fromUserId: 0, fromDeviceId: 0, totalDeviceCount: 0, receivedCount: 0, seenCount: 0, roomId: 0, type: "text", messageBody: MessageBody(text: "\(Int.random(in: 4...400)),  i: ~\(i)"), createdAt: 23))
        }
        messagesSubject.send(array)
        
        super.init(repository: repository, coordinator: coordinator)
    }

    func addMessage(message: Message) {
        var value = messagesSubject.value
        value.append(message)
        messagesSubject.send(value)
    }
    
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
            print("creating room response: ", response)
        }.store(in: &subscriptions)
    }
    
    func sendMessage(text: String) {
        guard let room = room else { return }
        let message = MessageBody(text: text)
        
        networkRequestState.send(.started())
        repository.sendTextMessage(message: message, roomId: room.id).sink { completion in
            self.networkRequestState.send(.finished)
            switch completion {
                
            case .finished:
                break
            case .failure(let error):
                print("send message: ", error)
            }
        } receiveValue: { response in
            print(response)
            guard let message = response.data?.message else { return }
            self.addMessage(message: message)
        }.store(in: &subscriptions)
    }
}
