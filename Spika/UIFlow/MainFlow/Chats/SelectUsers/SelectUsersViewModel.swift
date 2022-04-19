//
//  SelectUsersViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import Combine

class SelectUsersViewModel: BaseViewModel {
    
    let contactsSubject = CurrentValueSubject<[[User]], Never>([])
    let selectedUsersSubject = CurrentValueSubject<[User], Never>([])
    var users : [User] = []
    
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
                self.users = list
                self.updateContactsUI(list: list)
            }
            
        }.store(in: &subscriptions)
    }
    
    func updateContactsUI(list: [User]) {
          
        var tableAppUsers = Array<Array<User>>()
        for appUser in list {
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
            let filteredContacts = users.filter{ $0.displayName!.lowercased().contains(filter.lowercased()) }
            updateContactsUI(list: filteredContacts)
        }
    }
    
    func presentNewGroupScreen() {
        getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: selectedUsersSubject.value)
    }
    
    
}
