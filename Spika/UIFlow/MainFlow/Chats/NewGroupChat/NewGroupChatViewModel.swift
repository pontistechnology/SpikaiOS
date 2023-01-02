//
//  NewGroupChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import Combine

class NewGroupChatViewModel: BaseViewModel {
    
    let selectedUsers: CurrentValueSubject<[User],Never>
    
    init(repository: Repository, coordinator: Coordinator, selectedUsers: [User]) {
//        self.selectedUsers = selectedUsers
        self.selectedUsers = CurrentValueSubject(selectedUsers)
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func createRoom(name: String) {
        repository.createOnlineRoom(name: name, users: selectedUsers.value).sink { [weak self] completion in
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
            self?.getAppCoordinator()?.dismissViewController()
        }.store(in: &subscriptions)
    }
}
