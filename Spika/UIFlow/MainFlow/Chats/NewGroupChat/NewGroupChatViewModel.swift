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
    
    func removeUser(user: User) {
        var currentUsers = selectedUsers.value
        currentUsers.removeAll(where: { $0.id == user.id })
        self.selectedUsers.send(currentUsers)
    }
    
    func createRoom(name: String) {
        if let fileData = fileData,
           let fileUrl = repository.saveDataToFile(fileData, name: "newAvatar"){
            repository.uploadWholeFile(fromUrl: fileUrl, mimeType: "image/*", metaData: MetaData(width: 72, height: 72, duration: 0), specificFileName: nil)
                .sink { [weak self] completion in
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
                    guard let id = file?.id else { return }
                    self.finalizeRoomCreation(name: name, avatarId: id)
                }.store(in: &subscriptions)
        } else {
            self.finalizeRoomCreation(name: name, avatarId: nil)
        }
    }
    
    func finalizeRoomCreation(name: String, avatarId: Int64?) {
//        repository.createOnlineRoom(name: name,
//                                    avatarId: avatarId,
//                                    users: selectedUsers.value).sink { [weak self] completion in
//            guard let _ = self else { return }
//            switch completion {
//            case let .failure(error):
//                print(error)
//                break
//            case .finished:
//                break
//            }
//        } receiveValue: { [weak self] response in
//            if let room = response.data?.room {
//                print("There is online room.")
//                self?.networkRequestState.send(.finished)
//                self?.saveLocalRoom(room: room)
//            }
//        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveLocalRooms(rooms: [room])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case .finished:
                print("saved to local DB")
            case .failure(_):
                print("saving to local DB failed")
            }
        } receiveValue: { [weak self] rooms in
            guard let room = rooms.first else { return }
            self?.getAppCoordinator()?.dismissViewController()
            self?.getAppCoordinator()?.presentCurrentChatScreen(room: room)
        }.store(in: &subscriptions)
    }
    
}
