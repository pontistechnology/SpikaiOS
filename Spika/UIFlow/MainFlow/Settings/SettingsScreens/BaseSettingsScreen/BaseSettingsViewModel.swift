//
//  BaseSettingsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 23.01.2023..
//

import Foundation
import Combine

class BaseSettingsViewModel: BaseViewModel {
    
    let user = CurrentValueSubject<User?,Error>(nil)
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.loadLocalUser()
        self.fetchUserDetails()
    }
    
    private func loadLocalUser() {
        let ownId = self.repository.getMyUserId()
        self.repository.getLocalUser(withId: ownId)
            .sink { _ in
            } receiveValue: { [weak self] user in
                self?.user.send(user)
            }.store(in: &self.subscriptions)
    }
    
    private func fetchUserDetails() {
        self.repository.fetchMyUserDetails()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { c in
            }, receiveValue: { [weak self] responseModel in
                self?.user.send(responseModel.data?.user)
            }).store(in: &self.subscriptions)
    }
    
    // TODO: - check with Vedran
    func saveUser(user: User) {
//        self.repository.saveUserInfo(user: user, device: nil)
        self.repository.saveUsers([user])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let _ = self else { return }
                switch completion {
                case let .failure(error):
                    print("Could not save user: \(error)")
                default: break
                }
            } receiveValue: { [weak self] users in
                guard users.count == 1, let user = users.first else { return }
                self?.user.send(user)
            }.store(in: &subscriptions)

    }
    
}
