//
//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class ContactsViewModel: BaseViewModel {
    
    let chatsSubject = CurrentValueSubject<[Chat], Never>([])
    lazy var namesPublisher   = CurrentValueSubject<[String], Never>([])
    lazy var lettersPublisher = CurrentValueSubject<[String], Never>([])
    lazy var models = CurrentValueSubject<[AppUser], Never>([])
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
    }
    
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
    
    func addUserToChat(chat: Chat, user: User) {
        repository.addUserToChat(chat: chat, user: user).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { _ in
            self.getChats()
        }.store(in: &subscriptions)
    }
    
    func getUsersForChat(chat: Chat) {
        repository.getUsersForChat(chat: chat).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { users in
            print(users)
        }.store(in: &subscriptions)
    }
    
    func saveMessage(message: Message) {
        repository.saveMessage(message).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get message: \(error)")
            default: break
            }
        } receiveValue: { message in
            print(message)
        }.store(in: &subscriptions)
    }
    
    func getMessagesForChat(chat: Chat) {
        repository.getMessagesForChat(chat: chat).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get messages: \(error)")
            default: break
            }
        } receiveValue: { messages in
            print(messages)
        }.store(in: &subscriptions)
    }
    
    func testtest(_ name: String) {
        var names = namesPublisher.value
        var letters = lettersPublisher.value
        names.append(name)
        names.sort()
        let firstChar = String(name.prefix(1))
        if !letters.contains(firstChar) {
            letters.append(firstChar)
            letters.sort()
        }
        namesPublisher.send(names)
        lettersPublisher.send(letters)
    }
    
    func testLetter (_ model: AppUser) {
        if let firstChar = model.displayName?.prefix(1) {
            var letters = lettersPublisher.value
            let firstChar = firstChar
            if !letters.contains(String(firstChar)) {
                letters.append(String(firstChar))
                letters.sort()
            }
            lettersPublisher.send(letters)
        }
    }
    
    func getContacts() {
        ContactsUtils.getContacts().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get contacts: \(error)")
            default: break
            }
        } receiveValue: { contacts in
            print(contacts)
            var contacts = contacts
            for (index, contact) in contacts.enumerated() {
                contacts[index] = contact.getSHA256()
            }
            print(contacts)
            self.postContacts(hashes: contacts)
            
        }.store(in: &subscriptions)
    }
    
    func postContacts(hashes: [String]) {
        repository.postContacts(hashes: hashes).sink { completion in
            switch completion {
            case let .failure(error):
                print("post contacts error: ", error)
            default:
                break
            }
        } receiveValue: { response in
            print("Success: ", response)
        }.store(in: &subscriptions)
    }
    
    func getOnlineContacts(page: Int) {
        repository.getContacts(page: page).sink { completion in
            switch completion {
            case let .failure(error):
                print("get contacts error: ", error)
            default:
                break
            }
        } receiveValue: { response in
            print("Success: ", response)
            self.test(response: response)
            
            if let list = response.data?.list {
               
//                models.send(completion: list)
            }
            
        }.store(in: &subscriptions)
    }
    
    func test(response: ContactsResponseModel) {
        if let list = response.data?.list {
            var appUsers = Array<AppUser>()
            for user in list {
                testtest(user.displayName ?? "undefined")
                
                let appUser = AppUser(id: 2, displayName: user.displayName, avatarUrl: user.avatarUrl, telephoneNumber: "kurcina", telephoneNumberHashed: "", emailAddress: "", createdAt: 0)
                appUsers.append(appUser)
                
            }
            
            models.send(appUsers)
        }
    }
}
