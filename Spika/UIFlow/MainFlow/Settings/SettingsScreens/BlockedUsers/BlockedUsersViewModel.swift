//
//  BlockedUsersViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation
import Combine

class BlockedUsersViewModel: BaseSettingsViewModel {
    
    let blockedUsers = CurrentValueSubject<[User]?,Never>(nil)
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.fetchBlockedUsers()
    }
 
    func fetchBlockedUsers() {
        repository.getBlockedUsers()
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self.getAppCoordinator()?
                        .showError(message: .getStringFor(.somethingWentWrongFetchingBlockedUsers))
                    return
                }
            } receiveValue: { [weak self] response in
                self?.blockedUsers.send(response.data.blockedUsers)
            }.store(in: &subscriptions)
    }
    
}
