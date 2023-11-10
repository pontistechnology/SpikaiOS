//
//  Settings2ViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import Foundation

class Settings2ViewModel: BaseViewModel, ObservableObject {
    @Published var user: User?
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        loadLocalUser()
    }
    
    private func loadLocalUser() {
        let ownId = self.repository.getMyUserId()
        self.repository.getLocalUser(withId: ownId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] user in
                self?.user = user
            }.store(in: &self.subscriptions)
    }
    
    func onAppereanceClick() {
        getAppCoordinator()?.presentAppereanceSettingsScreen()
    }
    
    func onPrivacyClick() {
        getAppCoordinator()?.presentPrivacySettingsScreen()
    }
    
    
}
