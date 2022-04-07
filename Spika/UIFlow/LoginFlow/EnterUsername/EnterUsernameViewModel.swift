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
        if let imageFileData = imageFileData {
            let tuple = repository.uploadWholeFile(data: imageFileData)
            let totalNumberOfChunks = CGFloat(tuple.totalChunksNumber)
            
            tuple.publisher.sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    PopUpManager.shared.presentAlert(errorMessage: "Error with file upload: \(error)")
                default:
                    break
                }
            } receiveValue: { [weak self] chunkResponse in
                print("chunkResponse: ", chunkResponse)
                if let uploadedNumberOfChunks = chunkResponse.data?.uploadedChunks?.count {
                    self?.uploadProgressPublisher.send(CGFloat(uploadedNumberOfChunks) / totalNumberOfChunks)
                }
//                if let file = chunkResponse.data?.file {
//                    self?.updateInfo(username: username, avatarUrl: file.path)
//                }
            }.store(in: &subscriptions)
        } else {
            self.updateInfo(username: username)
        }
    }
    
    private func updateInfo(username: String, avatarUrl: String? = nil) {
        networkRequestState.send(.started())
        repository.updateUser(username: username, avatarURL: avatarUrl, telephoneNumber: nil, email: nil).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                print("ERROR: ", error)
                PopUpManager.shared.presentAlert(errorMessage: "Username error: \(error)")
            case .finished:
                self?.presentHomeScreen()
            }
        } receiveValue: { response in
            guard let user = response.data?.user else { return }
            self.repository.saveUserInfo(user: user, device: nil)
            print(response)
        }.store(in: &subscriptions)
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen()
    }
}
