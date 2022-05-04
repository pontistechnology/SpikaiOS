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
    
//    func getUsersAndUpdateUI() {
//        repository.getUsers().sink { [weak self] completion in
//            guard let _ = self else { return }
//            switch completion {
//            case let .failure(error):
//                print("Could not get users: \(error)")
//            default: break
//            }
//        } receiveValue: { [weak self] users in
//            guard let self = self else { return }
//            print("Read users from DB: \(users)")
//            self.users = users
//            self.updateContactsUI(list: users)
//        }.store(in: &subscriptions)
//    }
    
    func updateUsersFromFrc(_ userEntities: [UserEntity]) {
        print (userEntities)
        
        self.users = []
        for userEntity in userEntities {
            if let user = User(entity: userEntity) {
                users.append(user)
            }
        }
        self.updateContactsUI(list: users)
        
//        self.users = users
//        self.updateContactsUI(list: users)
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
                self.repository.updateUsersWithContactData(list)
            }
                        
            if let limit = response.data?.limit, let count = response.data?.count {
                if page * limit < count {
                    self.getOnlineContacts(page: page + 1)
                } else {
//                    self.getUsersAndUpdateUI()
                }
            }
        }.store(in: &subscriptions)
    }
    
    func updateContactsUI(list: [User]) {
        //TODO: check if sort needed
        let sortedList = list.sorted()
          
        var tableAppUsers = Array<Array<User>>()
        for user in sortedList {

            let char1 = user.getDisplayName().prefix(1)
            if let char2 = tableAppUsers.last?.last?.getDisplayName().prefix(1), char1.localizedLowercase == char2.localizedLowercase {
                tableAppUsers[tableAppUsers.count - 1].append(user)
            } else {
                tableAppUsers.append([user])
            }
        }
        
        contactsSubject.send(tableAppUsers)
        
    }
    
    func filterContactsUI(filter: String) {
        if filter.isEmpty {
            updateContactsUI(list: users)
        } else {
            let filteredContacts = users.filter{ $0.getDisplayName().localizedStandardContains(filter) }
            updateContactsUI(list: filteredContacts)
        }
    }
}
