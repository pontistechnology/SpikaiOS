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
    
    func updateUsersFromFrc(_ userEntities: [UserEntity]) {
        print (userEntities)
        
        self.users = []
        for userEntity in userEntities {
            if let user = User(entity: userEntity) {
                users.append(user)
            }
        }
        self.updateContactsUI(list: users)
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
                self.users = list
                self.updateContactsUI(list: list)
            }
            
        }.store(in: &subscriptions)
    }
    
    func updateContactsUI(list: [User]) {
          
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
    
    func presentNewGroupScreen() {
        getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: selectedUsersSubject.value)
    }
    
    
}
