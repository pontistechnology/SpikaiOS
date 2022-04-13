//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class ContactsViewModel: BaseViewModel {
    
    let contactsSubject = CurrentValueSubject<[[LocalUser]], Never>([])
    var users = Array<LocalUser>()
    
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func showDetailsScreen(user: LocalUser) {
        getAppCoordinator()?.presentDetailsScreen(user: user)
    }
    
    func getUsersAndUpdateUI() {
        repository.getUsers().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { users in
            print("Read users from DB: \(users)")
            self.users = users
            self.updateContactsUI(list: users)
        }.store(in: &subscriptions)
    }
    
    func saveUsers(_ users: [User]) {
        var dbUsers = [LocalUser]()
        for user in users {
            let dbUser = LocalUser(user: user)
            dbUsers.append(dbUser)
        }
        repository.saveUsers(dbUsers).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not save user: \(error)")
            default: break
            }
        } receiveValue: { users in
            print("Saved users to DB: \(users)")
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
    
    /// TODO: add paging
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
                self.saveUsers(list)
            }
            if let limit = response.data?.limit, let count = response.data?.count {
                if page * limit < count {
                    self.getOnlineContacts(page: page + 1)
                } else {
                    self.getUsersAndUpdateUI()
                }
            }
        }.store(in: &subscriptions)
    }
    
    func updateContactsUI(list: [LocalUser]) {
        
//        let appUser1 = AppUser(id: 100, displayName: "Ćap", avatarUrl: "bla", telephoneNumber: "000", telephoneNumberHashed: nil, emailAddress: nil, createdAt: 0)
//        let appUser2 = AppUser(id: 100, displayName: "Cup", avatarUrl: "bla", telephoneNumber: "000", telephoneNumberHashed: nil, emailAddress: nil, createdAt: 0)
//        let appUser3 = AppUser(id: 100, displayName: "Ćop", avatarUrl: "bla", telephoneNumber: "000", telephoneNumberHashed: nil, emailAddress: nil, createdAt: 0)
//        var testList = list
//        testList.append(appUser1)
//        testList.append(appUser2)
//        testList.append(appUser3)
        
        //TODO: check if sort needed
        let sortedList = list.sorted()
        
//        let sortedList = list.sorted(using: .localizedStandard)
        
//        var yuyu = ["blabla", "blublu"]
//        var testList = yuyu.sort(using: .localizedStandard)
        
//        let appUser = AppUser(id: 100, displayName: "Tito", avatarUrl: "bla", telephoneNumber: "000", telephoneNumberHashed: nil, emailAddress: nil, createdAt: 0)
//        sortedList.append(appUser)
//        let sortedList = list.sort(using: .localizedStandard)
          
        var tableAppUsers = Array<Array<LocalUser>>()
        for user in sortedList {
            if let char1 = user.displayName?.prefix(1), let char2 = tableAppUsers.last?.last?.displayName?.prefix(1), char1 == char2 {
                print("\(char1.localizedLowercase) \(char2.localizedLowercase) \(char1.localizedCompare(char2) == .orderedSame)")
                tableAppUsers[tableAppUsers.count - 1].append(user)
            } else {
                if let char1 = user.displayName?.prefix(1), let char2 = tableAppUsers.last?.last?.displayName?.prefix(1) {
                    print("\(char1.localizedLowercase) \(char2.localizedLowercase) \(char1.localizedCompare(char2) == .orderedSame)")
                }
                tableAppUsers.append([user])
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
