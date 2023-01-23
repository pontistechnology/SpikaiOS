//
//  SettingsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class SettingsViewModel: BaseViewModel {
    
    let user = CurrentValueSubject<User?,Error>(nil)
    
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.fetchUserDetails()
    }
    
    func onChangeUserName(newName: String) {
        guard newName != self.user.value?.getDisplayName() else { return }
        networkRequestState.send(.started())
        self.updateInfo(username: newName, avatarFileId: self.user.value?.avatarFileId)
    }
    
    func onChangeUserAvatar(imageFileData: Data?) {
        if let imageFileData = imageFileData {
            let tuple = repository.uploadWholeFile(data: imageFileData, mimeType: "image/*", metaData: MetaData(width: 512, height: 512, duration: 0))
            tuple.sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.showError("Error with file upload: \(error)")
                }
            } receiveValue: { [weak self] (file, percent) in
                guard let self = self else { return }
                guard let file = file else { return }
                self.updateInfo(username: self.user.value?.getDisplayName() ?? "", avatarFileId: file.id ?? 0)
            }.store(in: &subscriptions)
        }
    }
    
    private func updateInfo(username: String, avatarFileId: Int64? = nil) {
        networkRequestState.send(.started())
        repository.updateUser(username: username, avatarFileId: avatarFileId, telephoneNumber: nil, email: nil).sink { [weak self] completion in
            guard let self = self else { return }
            self.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                print("ERROR: ", error)
                self.showError("Username error: \(error)")
            case .finished:
                return
            }
        } receiveValue: { [weak self] response in
            guard let self = self,
                  let user = response.data?.user else { return }
            self.repository.saveUserInfo(user: user, device: nil)
            self.user.send(user)
        }.store(in: &subscriptions)
    }
    
    func fetchUserDetails() {
        self.repository.fetchMyUserDetails()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { c in
            }, receiveValue: { [weak self] responseModel in
                self?.user.send(responseModel.data?.user)
            }).store(in: &self.subscriptions)
    }
    
}
