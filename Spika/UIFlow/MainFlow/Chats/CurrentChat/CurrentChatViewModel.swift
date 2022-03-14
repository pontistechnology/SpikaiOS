//
//  CurrentChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine

class CurrentChatViewModel: BaseViewModel {
    
    let friendUser: AppUser
    var room: Room?
    let testMessagesSubject = CurrentValueSubject<[Message2], Never>([
        Message2(id: 0, fromUserId: 0, fromDeviceId: 0, totalDeviceCount: 0, receivedCount: 0, seenCount: 0, roomId: 0, type: "text", messageBody: MessageBody(text: "neron"), createdAt: 23)
    ])
    
    
    init(repository: Repository, coordinator: Coordinator, friendUser: AppUser) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
    }

    func addMessage(message: Message2) {
        var value = testMessagesSubject.value
        value.append(message)
        testMessagesSubject.send(value)
    }
    
    func checkRoom(forUserId userId: Int)  {
        networkRequestState.send(.started())
        repository.checkRoom(forUserId: userId).sink { completion in
            switch completion {
            case .finished:
                print("check finished")
            case .failure(_):
                print("error")
                self.networkRequestState.send(.finished)
            }
        } receiveValue: { response in
            print(response.data?.room.id)
            
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
            switch completion {
                
            case .finished:
                print("finished")
                self.networkRequestState.send(.finished)
            case .failure(_):
                print("error")
                self.networkRequestState.send(.finished)
            }
        } receiveValue: { response in
            print(response)
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
