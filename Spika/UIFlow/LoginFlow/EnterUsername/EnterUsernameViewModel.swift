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
    
    let isUsernameWrong = CurrentValueSubject<Bool, Never>(true)
    
    func updateUser(username: String, imageFileData: Data?) {
        networkRequestState.send(.started)
        
        if let imageFileData = imageFileData {
            repository.uploadWholeFile(data: imageFileData).sink { completion in
                
            } receiveValue: { [weak self] lastChunkResponse in
                guard let lastChunkResponse = lastChunkResponse else { return }
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
                print("updateUsername error: ", error)
            case .finished:
                self?.presentHomeScreen()
            }
        } receiveValue: { _ in }.store(in: &subscriptions)
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen()
    }
}
