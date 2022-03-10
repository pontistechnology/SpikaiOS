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
    let contactsSubject = CurrentValueSubject<[[AppUser]], Never>([])
    var users = Array<AppUser>()
    
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
    
    func showDetailsScreen(user: AppUser) {
        getAppCoordinator()?.presentDetailsScreen(user: user)
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
            if let list = response.data?.list {
                self.users = list
                self.updateContactsUI(list: list)
            }
            
        }.store(in: &subscriptions)
    }
    
    func updateContactsUI(list: [AppUser]) {
        
        //TODO: check if sort needed
        var sortedList = list.sorted()
        
//        list.sorted(using: .localizedStandard)
//        let appUser = AppUser(id: 100, displayName: "Tito", avatarUrl: "bla", telephoneNumber: "000", telephoneNumberHashed: nil, emailAddress: nil, createdAt: 0)
//        sortedList.append(appUser)
//        let sortedList = list.sort(using: .localizedStandard)
          
        var tableAppUsers = Array<Array<AppUser>>()
        for appUser in sortedList {
            if let char1 = appUser.displayName?.prefix(1), let char2 = tableAppUsers.last?.last?.displayName?.prefix(1), char1 == char2 {
                tableAppUsers[tableAppUsers.count - 1].append(appUser)
            } else {
                tableAppUsers.append([appUser])
            }
        }
        
        contactsSubject.send(tableAppUsers)
        
    }
    
    func filterContactsUI(filter: String) {
        if filter.isEmpty {
            updateContactsUI(list: users)
        } else {
            let filteredContacts = users.filter{ $0.displayName!.localizedStandardContains(filter) }
            updateContactsUI(list: filteredContacts)
        }
    }
}
