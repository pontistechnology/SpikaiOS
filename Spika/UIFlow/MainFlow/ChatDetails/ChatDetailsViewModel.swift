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
                guard let self = self else {
                    return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken).eraseToAnyPublisher()
                }
                return self.repository.updateRoomUsers(roomId: self.room.value.id, userIds: userIds)
            }
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongAddingUsers))
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
                guard let blockedUsers = blockedUsers else { return false }
                guard self?.room.value.users.count == 2 else { return false }
                let roomUserIds = self?.room.value.users.map { $0.userId } ?? []
                return Set(blockedUsers).intersection(Set(roomUserIds)).count > 0
            }
            .subscribe(self.isBlocked)
            .store(in: &self.subscriptions)
    }
    
    func muteUnmute(mute: Bool) {
        self.repository
            .muteUnmuteRoom(roomId: self.room.value.id, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.updateRoomIsMuted(room: self.room.value, isMuted: !self.room.value.muted)
                    break
                case .failure(_):
                    let message: String = mute ? .getStringFor(.somethingWentWrongMutingRoom) : .getStringFor(.somethingWentWrongUnmutingRoom)
                    self.getAppCoordinator()?
                        .showError(message: message)
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
                case .failure(let error):
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
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.allroomsprinter()
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] room in
                self?.room.send(room)
            }.store(in: &self.subscriptions)
    }
    
    func deleteRoomComfirmed() {
        self.repository.deleteOnlineRoom(forRoomId: self.room.value.id)
            .sink { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongDeletingTheRoom))
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
                    self?.getAppCoordinator()?.showError(message: .getStringFor(.somethingWentWrongDeletingTheRoom))
                case.finished:
                    self?.getAppCoordinator()?.popTopViewController()
                    self?.getAppCoordinator()?.popTopViewController()
                    return
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteRoom() {
        self.getAppCoordinator()?.showAlertView(title: .getStringFor(.deleteTheRoom),
                                                message: .getStringFor(.deleteTheRoom),
                                                buttons: [AlertViewButton.regular(title: .getStringFor(.cancel)),
                                                          AlertViewButton.regular(title: .getStringFor(.delete))])
        .sink(receiveValue: { type in
            switch type {
            case .dismiss:
                ()
            case .alertViewTap(let index):
                guard index == 1 else { return }
                self.deleteRoomComfirmed()
            }
        }).store(in: &self.subscriptions)
    }
    
    func changeAvatar(image: Data) {
        repository.uploadWholeFile(data: image, mimeType: "image/*", metaData: MetaData(width: 72, height: 72, duration: 0))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.uploadProgressPublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    self?.showError("Error with file upload: \(error)")
                }
            } receiveValue: { [weak self] (file, percent) in
                guard let self = self else { return }
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
