//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit
import Combine

class ChatDetailsViewModel: BaseViewModel {
    let room: CurrentValueSubject<Room,Never>
    
    private let updateContacts = PassthroughSubject<[Int64],Never>()
    
    let uploadProgressPublisher = PassthroughSubject<CGFloat, Error>()
    
    let isBlocked = CurrentValueSubject<Bool,Never>(false)
    
    init(repository: Repository, coordinator: Coordinator, room: CurrentValueSubject<Room,Never>) {
        self.room = room
        super.init(repository: repository, coordinator: coordinator)
        self.setupBindings()
    }
    
    func setupBindings() {
        self.updateContacts
            .flatMap { [weak self] userIds in
                guard let self else {
                    return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken).eraseToAnyPublisher()
                }
                return self.repository.updateRoomUsers(roomId: self.room.value.id, userIds: userIds)
            }
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.showError(.getStringFor(.somethingWentWrongAddingUsers))
                case.finished:
                    return
                }
            } receiveValue: { [weak self] responseModel in
                guard let room = responseModel.data?.room else { return }
                self?.updateRoom(room: room)
            }.store(in: &self.subscriptions)
        
        self.repository.blockedUsersPublisher()
            .receive(on: DispatchQueue.main)
            .map { [weak self] blockedUsers in
                guard let blockedUsers = blockedUsers,
                      self?.room.value.type == .privateRoom else { return false }
                let roomUserIds = self?.room.value.users.map { $0.userId } ?? []
                return Set(blockedUsers).intersection(Set(roomUserIds)).count > 0
            }
            .subscribe(self.isBlocked)
            .store(in: &self.subscriptions)
    }
    
    func onChangeChatName(newName: String) {
        guard newName != self.room.value.name else { return }
        networkRequestState.send(.started())
        
        self.repository.updateRoomName(roomId: self.room.value.id, newName: newName)
            .sink { [weak self] c in
                self?.networkRequestState.send(.finished)
                switch c {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] room in
                guard let newRoom = room.data?.room else { return }
                self?.saveLocalRoom(room: newRoom)
            }.store(in: &self.subscriptions)
    }
    
    func muteUnmute(mute: Bool) {
        self.repository
            .muteUnmuteRoom(roomId: self.room.value.id, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.updateRoomIsMuted(room: self.room.value, isMuted: !self.room.value.muted)
                    break
                case .failure(_):
                    let message: String = mute ? .getStringFor(.somethingWentWrongMutingRoom) : .getStringFor(.somethingWentWrongUnmutingRoom)
                    self.showError(message)
                    self.room.send(self.room.value)
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func pinUnpin(pin: Bool) {
        self.repository
            .pinUnpinRoom(roomId: self.room.value.id, pin: pin)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.updateRoomIsPinned(room: self.room.value, isPinned: !self.room.value.pinned)
                    break
                case .failure(_):
                    let message: String = pin ? .getStringFor(.somethingWentWrongMutingRoom) : .getStringFor(.somethingWentWrongUnmutingRoom)
                    self.showError(message)
                    self.room.send(self.room.value)
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func blockOrUnblock() {
        if self.isBlocked.value {
            self.unblockUser()
        } else {
            self.blockUser()
        }
    }
    
    func blockUser() {
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room.value.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        self.repository.blockUser(userId: contact.userId)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateBlockedList()
                case .failure(_):
                    ()
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func unblockUser() {
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room.value.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        self.repository.unblockUser(userId: contact.userId)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateBlockedList()
                case .failure(_):
                    ()
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func updateBlockedList() {
        repository.getBlockedUsers()
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    return
                }
            } receiveValue: { [weak self] response in
                self?.repository.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subscriptions)
    }
    
    func onAddNewUser() {
        let usersSelected = PassthroughSubject<[User],Never>()
        self.getAppCoordinator()?.presentUserSelection(preselectedUsers: self.room.value.users.map { $0.user }, usersSelectedPublisher: usersSelected)

        usersSelected
            .map { [unowned self] newUsers in
                return self.room.value.users.map { $0.userId } + newUsers.map { $0.id }
            }
            .subscribe(self.updateContacts)
            .store(in: &self.subscriptions)
    }
    
    func removeUser(user: User) {
        if let roomUser = self.room.value.users.first(where: { $0.userId == user.id }), roomUser.isAdmin ?? false {
            return
        }
        
        var userIds = self.room.value.users.map { $0.userId }
        userIds.removeAll(where: { $0 == user.id })
        self.updateContacts.send(userIds)
    }
    
    func updateRoom(room: Room) {
        self.repository
            .updateRoomUsers(room: room )
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] room in
                self?.room.send(room)
            }.store(in: &self.subscriptions)
    }
    
    func deleteRoomConfirmed() {
        self.repository.deleteOnlineRoom(forRoomId: self.room.value.id)
            .sink { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.showError(.getStringFor(.somethingWentWrongDeletingTheRoom))
                case.finished:
                    guard let room = self?.room.value else { return }
                    self?.deleteLocalRoom(room: room)
                    return
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteLocalRoom(room: Room) {
        self.repository.deleteLocalRoom(roomId: room.id)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.showError(.getStringFor(.somethingWentWrongDeletingTheRoom))
                case.finished:
                    self?.getAppCoordinator()?.popTopViewController()
                    self?.getAppCoordinator()?.popTopViewController()
                    return
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteRoom() {
        self.getAppCoordinator()?.showAlert(title: .getStringFor(.areYouSureYoutWantToDeleteGroup),
                                            message: nil,
                                            style: .alert,
                                            actions: [AlertViewButton.destructive(title: .getStringFor(.delete))])
        .sink(receiveValue: { [weak self] tappedIndex in
            guard tappedIndex == 0 else { return }
            self?.deleteRoomConfirmed()
        })
        .store(in: &subscriptions)
    }
    
    func leaveRoomConfirmed() {
        repository.leaveOnlineRoom(forRoomId: self.room.value.id)
            .sink { [weak self] c in
                switch c {
                case .finished:
                    break
                case .failure(_):
                    self?.showError("Error leaving room")
                }
            } receiveValue: { [weak self] response in
                guard let roomData = response.data?.room else { return }
                self?.updateRoomUsers(room: roomData)
            }
            .store(in: &subscriptions)
    }
    
    func changeAvatar(image: Data?) {
        guard let image = image,
              let fileUrl = repository.saveDataToFile(image, name: "newAvatar")
        else {
            self.updateRoomWithAvatar(avatarId: 0)
            return
        }
        repository.uploadWholeFile(fromUrl: fileUrl, mimeType: "image/*", metaData: MetaData(width: 72, height: 72, duration: 0))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    self?.showError("Error with file upload: \(error)")
                }
            } receiveValue: { [weak self] (file, percent) in
                guard let self else { return }
                self.uploadProgressPublisher.send(percent)
                guard let id = file?.id else { return }
                self.updateRoomWithAvatar(avatarId: id)
            }.store(in: &subscriptions)
    }
    
    func updateRoomWithAvatar(avatarId: Int64) {
        repository.updateRoomAvatar(roomId: self.room.value.id, avatarId: avatarId)
            .sink { [weak self] c in
                switch c {
                case .finished:
                    break
                case let .failure(error):
                    self?.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    self?.showError("Error with file upload: \(error)")
                }
            } receiveValue: { response in
                guard let roomData = response.data?.room else { return }
                self.saveLocalRoom(room: roomData)
            }.store(in: &subscriptions)
    }
    
    func updateRoomIsMuted(room: Room, isMuted:Bool) {
        var mutableRoom = room
        mutableRoom.muted = isMuted
        self.saveLocalRoom(room: mutableRoom)
    }
    
    func updateRoomIsPinned(room: Room, isPinned:Bool) {
        var mutableRoom = room
        mutableRoom.pinned = isPinned
        self.saveLocalRoom(room: mutableRoom)
    }
    
    func updateRoomUsers(room: Room) {
        self.repository.updateRoomUsers(room: room)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("saved to local DB")
                case .failure(_):
                    print("saving to local DB failed")
                }
            } receiveValue: { [weak self] room in
                self?.room.send(room)
            }.store(in: &subscriptions)
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
            self?.room.send(room)
        }.store(in: &subscriptions)
    }
    
    deinit {
//        print("Deinit Works")
    }
    
}
