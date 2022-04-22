//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class ContactsViewModel: BaseViewModel {
    
    let contactsSubject = CurrentValueSubject<[[User]], Never>([])
    var users = Array<User>()
    
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func showDetailsScreen(user: User) {
        getAppCoordinator()?.presentDetailsScreen(user: user)
    }
    
    func getUsersAndUpdateUI() {
        repository.getUsers().sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { [weak self] users in
            guard let self = self else { return }
            print("Read users from DB: \(users)")
            self.users = users
            self.updateContactsUI(list: users)
        }.store(in: &subscriptions)
    }
    
    func saveUsers(_ users: [User]) {
        repository.saveUsers(users).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("Could not save user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] users in
            guard let _ = self else { return }
            print("Saved users to DB: \(users)")
        }.store(in: &subscriptions)
    }
    
    func getContacts() {
        ContactsUtils.getContacts().sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("Could not get contacts: \(error)")
            default: break
            }
        } receiveValue: { [weak self] contacts in
            guard let self = self else { return }
            print(contacts)
            self.repository.saveContacts(contacts).sink { completion in
                
            } receiveValue: { contactss in
                print("saved contatssssss", contactss)
            }.store(in: &self.subscriptions)

//            var contacts = contacts
//            for var contact in contacts {
//                contact.telephone = contact.telephone.getSHA256()
//            }
//
            let phoneHashes = contacts.map { $0.telephone.getSHA256() }
            print(phoneHashes)
            self.postContacts(hashes: phoneHashes)
            
        }.store(in: &subscriptions)
    }
    
    // TODO: add paging
    func postContacts(hashes: [String]) {
        repository.postContacts(hashes: hashes).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("post contacts error: ", error)
            default:
                break
            }
        } receiveValue: { [weak self] response in
            guard let _ = self else { return }
            print("Success: ", response)
        }.store(in: &subscriptions)
    }
    
    func getOnlineContacts(page: Int) {
        repository.getContacts(page: page).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("get contacts error: ", error)
            default:
                break
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("Success: ", response)
            if let list = response.data?.list {
                for var user in list {
                    self.repository.getContact(phoneNumber: user.telephoneNumber!).sink { [weak self] completion in
                        guard let _ = self else { return }
                        switch completion {
                        case let .failure(error):
                            print("cant find contact: ", user.telephoneNumber, " ",error)
                        default:
                            break
                        }
                    } receiveValue: { [weak self] contact in
                        print("contact found: ", contact.telephone)
                        user.givenName = contact.firstName
                        user.familyName = contact.lastName
                        self?.repository.saveUser(user)
                    }.store(in: &self.subscriptions)
                }
//                self.saveUsers(list)
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
    
    func updateContactsUI(list: [User]) {
        
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
          
        var tableAppUsers = Array<Array<User>>()
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
