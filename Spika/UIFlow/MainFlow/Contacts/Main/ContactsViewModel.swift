//  ContactsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class ContactsViewModel: BaseViewModel {
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func showDetailsScreen(user: User) {
        getAppCoordinator()?.presentDetailsScreen(user: user)
    }
    
    func saveUsers(_ users: [User]) {
        repository.saveUsers(users).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("Could not save user: \(error)")
            default: break
            }
        } receiveValue: { users in
        }.store(in: &subscriptions)
    }
    
    func getContacts() {
        ContactsUtils().getContacts().sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("Could not get contacts: \(error)")
            default: break
            }
        } receiveValue: { [weak self] contacts in
            guard let self = self else { return }
            self.repository.saveContacts(contacts).sink { completion in
                
            } receiveValue: { contactss in
//                print("saved contatssssss", contactss)
            }.store(in: &self.subscriptions)

            let phoneHashes = contacts.map { $0.telephone.getSHA256() }
//            print(phoneHashes)
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
//            print("Success: ", response)
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
//            print("Success: ", response)
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
}
