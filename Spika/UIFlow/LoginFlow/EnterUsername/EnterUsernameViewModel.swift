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
    
    func updateUser(username: String, imageFileData: Data?) {
        networkRequestState.send(.started)
        
        if let imageFileData = imageFileData {
            repository.uploadWholeFile(data: imageFileData).sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.networkRequestState.send(.finished)
                    PopUpManager.shared.presentAlert(errorMessage: "Error with file upload: \(error)")
                default:
                    break
                }
            } receiveValue: { [weak self] lastChunkResponse in
                self?.updateInfo(username: username, avatarUrl: lastChunkResponse.data?.file?.path)
            }.store(in: &subscriptions)
        } else {
            self.updateInfo(username: username)
        }
    }
    
    private func updateInfo(username: String? = nil, avatarUrl: String? = nil) {
        networkRequestState.send(.started)
        repository.updateUser(username: username, avatarURL: avatarUrl, telephoneNumber: nil, email: nil).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                PopUpManager.shared.presentAlert(errorMessage: "Username error: \(error)")
            case .finished:
                self?.presentHomeScreen()
            }
        } receiveValue: { _ in }.store(in: &subscriptions)
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen()
    }
}
