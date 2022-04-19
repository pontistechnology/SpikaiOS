//
//  NewGroupChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

class NewGroupChatViewModel: BaseViewModel {
    
    var selectedUsers: [User]
    
    init(repository: Repository, coordinator: Coordinator, selectedUsers: [User]) {
        self.selectedUsers = selectedUsers
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func createRoom(name: String) {
        repository.createRoom(name: name, users: selectedUsers).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print(error)
                break
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            guard let _ = self else { return }
            print("Create room response ", response)
        }.store(in: &subscriptions)

    }
}
