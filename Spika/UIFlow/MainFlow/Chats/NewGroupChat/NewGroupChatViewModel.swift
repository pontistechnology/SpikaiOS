//
//  NewGroupChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import Combine

class NewGroupChatViewModel: BaseViewModel {
    
    let selectedUsers: CurrentValueSubject<[User],Never>
    
    let uploadProgressPublisher = PassthroughSubject<CGFloat, Error>()
    var fileData: Data?
    
    init(repository: Repository, coordinator: Coordinator, selectedUsers: [User]) {
        self.selectedUsers = CurrentValueSubject(selectedUsers)
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func createRoom(name: String) {
        if let fileData = fileData {
            repository.uploadWholeFile(data: fileData)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                        self.showError("Error with file upload: \(error)")
                    }
                } receiveValue: { [weak self] (file, percent) in
                    guard let self = self else { return }
                    self.uploadProgressPublisher.send(percent)
                    self.finalizeRoomCreation(name: name, avatarId: file?.id)
                }.store(in: &subscriptions)
        } else {
            self.finalizeRoomCreation(name: name, avatarId: nil)
        }
       
    }
    
    func finalizeRoomCreation(name: String, avatarId: Int64?) {
        repository.createOnlineRoom(name: name,
                                    avatarId: avatarId,
                                    users: selectedUsers.value).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print(error)
                break
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            guard let _ = self else { return }
            print("Create room response ", response)
            self?.getAppCoordinator()?.dismissViewController()
        }.store(in: &subscriptions)
    }
    
    func removeUser(user: User) {
        var currentUsers = selectedUsers.value
        currentUsers.removeAll(where: { $0.id == user.id })
        self.selectedUsers.send(currentUsers)
    }
    
}
