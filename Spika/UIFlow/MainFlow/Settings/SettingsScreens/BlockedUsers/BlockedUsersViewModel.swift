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
    
    override init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher? = nil) {
        super.init(repository: repository, coordinator: coordinator)
        self.fetchBlockedUsers()
    }
 
    func fetchBlockedUsers() {
        repository.getBlockedUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self?.getAppCoordinator()?
                        .showError(message: .getStringFor(.somethingWentWrongFetchingBlockedUsers))
                    return
                }
            } receiveValue: { [weak self] response in
                self?.blockedUsers.send(response.data.blockedUsers)
            }.store(in: &subscriptions)
    }
    
    func unblockUserAt(index: Int) {
        guard let user = self.blockedUsers.value?[index] else { return }
        self.repository.unblockUser(userId: user.id)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateBlockedList()
                    self?.fetchBlockedUsers()
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongUnblockingUser))
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func updateBlockedList() {
        repository.getBlockedUsers()
            .sink { _ in
            } receiveValue: { [weak self] response in
                self?.repository.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subscriptions)
    }
    
}
