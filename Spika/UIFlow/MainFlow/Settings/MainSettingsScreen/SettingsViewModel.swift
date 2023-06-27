//
//  SettingsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class SettingsViewModel: BaseSettingsViewModel {
    
    func onChangeUserName(newName: String) {
        guard newName != self.user.value?.getDisplayName() else { return }
        networkRequestState.send(.started())
        self.updateInfo(username: newName, avatarFileId: self.user.value?.avatarFileId)
    }
    
    func onChangeUserAvatar(imageFileData: Data?) {
        guard let imageFileData = imageFileData,
              let fileUrl = repository.saveDataToFile(imageFileData, name: "newAvatar")
        else {
            self.updateInfo(username: self.user.value?.getDisplayName() ?? "", avatarFileId: 0)
            return
        }
        
        let tuple = repository.uploadWholeFile(fromUrl: fileUrl, mimeType: "image/*", metaData: MetaData(width: 512, height: 512, duration: 0), specificFileName: nil)
        tuple.sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                break
            case let .failure(error):
                self.showError("Error with file upload: \(error)")
            }
        } receiveValue: { [weak self] (file, percent) in
            guard let self else { return }
            guard let file = file else { return }
            self.updateInfo(username: self.user.value?.getDisplayName() ?? "", avatarFileId: file.id ?? 0)
        }.store(in: &subscriptions)
    }
    
    private func updateInfo(username: String, avatarFileId: Int64? = nil) {
        networkRequestState.send(.started())
        repository.updateUser(username: username, avatarFileId: avatarFileId, telephoneNumber: nil, email: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.networkRequestState.send(.finished)
                switch completion {
                case let .failure(error):
                    print("ERROR: ", error)
                    self.showError("Username error: \(error)")
                case .finished:
                    return
                }
            } receiveValue: { [weak self] response in
                guard let self,
                      let user = response.data?.user else { return }
                self.saveUser(user: user)
            }.store(in: &subscriptions)
    }
    
    func presentAppereanceSettingsScreen() {
        getAppCoordinator()?.presentAppereanceSettingsScreen()
    }
}
