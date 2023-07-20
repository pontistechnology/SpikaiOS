//
//  EnterUsernameViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Combine
import Foundation
import UIKit
import CryptoKit

class EnterUsernameViewModel: BaseViewModel {
    
    let uploadProgressPublisher = PassthroughSubject<CGFloat, Error>()
    
    func updateUser(username: String, imageFileData: Data?) {
        if let imageFileData = imageFileData,
           let fileUrl = repository.saveDataToFile(imageFileData, name: "newAvatar") {
            let tuple = repository.uploadWholeFile(fromUrl: fileUrl, mimeType: "image/*", metaData: MetaData(width: 512, height: 512, duration: 0), specificFileName: nil)
            tuple.sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    self.showError("Error with file upload: \(error)")
                }
            } receiveValue: { [weak self] (file, percent) in
                guard let self else { return }
                self.uploadProgressPublisher.send(percent)
                guard let file = file else { return }
                self.updateInfo(username: username, avatarFileId: file.id ?? 0)
            }.store(in: &subscriptions)
        } else {
            self.updateInfo(username: username)
        }
    }
    
    private func updateInfo(username: String, avatarFileId: Int64? = nil) {
        networkRequestState.send(.started())
        repository.updateUser(username: username, avatarFileId: avatarFileId, telephoneNumber: nil, email: nil).sink { [weak self] completion in
            guard let self else { return }
            self.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self.showError("Username error: \(error)")
            case .finished:
                self.presentHomeScreen()
            }
        } receiveValue: { [weak self] response in
            guard let self,
                  let user = response.data?.user else { return }
            self.repository.saveUserInfo(user: user, device: nil, telephoneNumber: nil)
        }.store(in: &subscriptions)
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true)
    }
}
