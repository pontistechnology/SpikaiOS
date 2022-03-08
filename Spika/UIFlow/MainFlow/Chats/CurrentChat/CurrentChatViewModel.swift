//
//  CurrentChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine

class CurrentChatViewModel: BaseViewModel {
    
    let user: AppUser
    var room: Room?
    let testMessagesSubject = CurrentValueSubject<[MessageTest], Never>([
        MessageTest(messageType: .text, textOfMessage: "prva", replyMessageId: nil, senderName: "anto", isMyMessage: false),
        MessageTest(messageType: .text, textOfMessage: "druga koja je malo duza hahfsajk fjksa nkjsanf kjsn jkfnsakj nfkjsan kjdn fkjnaskd njahah hah hah hahah ", replyMessageId: 0, senderName: "anto", isMyMessage: false),
        MessageTest(messageType: .text, textOfMessage: "druga koja je malo duza hahfsajk fjksa nkjsanf kjsn jkfnsakj nfkjsan kjdn fkjnaskd njahah hah hah hahah ", replyMessageId: 0, senderName: "anto", isMyMessage: true)
    ])
    
    
    init(repository: Repository, coordinator: Coordinator, user: AppUser) {
        self.user = user
        super.init(repository: repository, coordinator: coordinator)
    }

    func addMessage(message: MessageTest) {
        var value = testMessagesSubject.value
        value.append(message)
        testMessagesSubject.send(value)
    }
    
    func checkRoom(forUserId userId: Int)  {
        networkRequestState.send(.started)
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
                self.createRoom(userId: self.user.id)
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
        let message = MessageTest(messageType: .text, textOfMessage: text, replyMessageId: nil, senderName: "Nikola", isMyMessage: true)
        
        guard let room = room else {
            return
        }
        networkRequestState.send(.started)
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
            guard let message = response.data?.message.messageBody else { return }
            self.addMessage(message: message)
        }.store(in: &subscriptions)

    }
    
    
}
