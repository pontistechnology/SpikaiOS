//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

class HomeViewModel: BaseViewModel {
    
    let chatsSubject = CurrentValueSubject<[Chat], Never>([])
    
    func getPosts() {
        self.repository.getPosts().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get posts: \(error)")
            default: break
            }
        } receiveValue: { posts in
            print(posts)
        }.store(in: &subscriptions)
    }
    
    func showDetailsScreen(id: Int) {
        getAppCoordinator()?.presentDetailsScreen(id: id)
    }
    
    func getChats() {
        repository.getChats().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get chats: \(error)")
            default: break
            }
        } receiveValue: { [weak self] chats in
            self?.chatsSubject.value = chats
        }.store(in: &subscriptions)

    }
    
    func createChat(name: String, type: String, id: Int) {
        let chat = Chat(name: name, id: id, type: type)
        repository.createChat(chat).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get chats: \(error)")
            default: break
            }
        } receiveValue: { [weak self] chat in
            var chats = self?.chatsSubject.value
            chats?.append(chat)
            self?.chatsSubject.value = chats ?? []
        }.store(in: &subscriptions)

    }
    
    func updateChat(name: String, type: String, id: Int) {
        let chat = Chat(name: name, id: id, type: type)
        repository.updateChat(chat).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get chats: \(error)")
            default: break
            }
        } receiveValue: { chat in
            print(chat)
        }.store(in: &subscriptions)

    }
    
    func getUsers() {
        repository.getUsers().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { users in
            print(users)
        }.store(in: &subscriptions)

    }
    
}
