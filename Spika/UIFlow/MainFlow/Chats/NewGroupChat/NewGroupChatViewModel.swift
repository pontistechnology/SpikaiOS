//
//  NewGroupChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

class NewGroupChatViewModel: BaseViewModel {
    
    var selectedUsers: [AppUser]
    
    init(repository: Repository, coordinator: Coordinator, selectedUsers: [AppUser]) {
        self.selectedUsers = selectedUsers
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func createRoom(name: String) {
        repository.createRoom(name: name, users: selectedUsers).sink { completion in
            switch completion {
            case let .failure(error):
                print(error)
                break
            case .finished:
                break
            }
        } receiveValue: { response in
            print("Create room response ", response)
        }.store(in: &subscriptions)

    }
}
