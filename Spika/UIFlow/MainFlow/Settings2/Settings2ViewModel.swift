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
    
    func askForDeleteConformation() {
        // TODO: - change to loc. strings when design is ready
        getAppCoordinator()?.showAlert(title: "Delete Account?", message: "You will be logged out and ALL your data will be deleted.", style: .alert, actions: [.destructive(title: "Delete")])
            .sink(receiveValue: { [weak self] choice in
                self?.deleteMyAccount()
            }).store(in: &subscriptions)
    }
    
    func deleteMyAccount() {
        networkRequestState.send(.started())
        repository.deleteMyAccount().sink { [weak self] _ in
            self?.networkRequestState.send(.finished)
        } receiveValue: { [weak self] response in
            guard let isDeleted = response.data?.deleted, isDeleted
            else { return }
            self?.repository.deleteAllFiles()
            self?.repository.deleteUserDefaults()
            self?.repository.deleteLocalDatabase()
            self?.getAppCoordinator()?.start()
        }.store(in: &subscriptions)
    }
}
