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
    
    let isAdmin = CurrentValueSubject<Bool,Never>(false)
    
    private let updateContacts = PassthroughSubject<[Int64],Never>()
    
    init(repository: Repository, coordinator: Coordinator, room: CurrentValueSubject<Room,Never>) {
        self.room = room
        super.init(repository: repository, coordinator: coordinator)
        self.setupBindings()
    }
    
    func setupBindings() {
        self.room
            .map { [weak self] room in
                guard let `self` = self else { return false }
                return room.users.filter { $0.userId == self.getMyUserId() }.first?.isAdmin ?? false
            }.subscribe(self.isAdmin)
            .store(in: &self.subscriptions)
        
        self.updateContacts
            .flatMap { [weak self] userIds in
                guard let `self` = self else {
                    return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken).eraseToAnyPublisher()
                }
                return self.repository.updateRoomUsers(roomId: self.room.value.id, userIds: userIds)
            }
            .sink { [weak self] c in
                switch c {
                case .failure(_):
                    self?.getAppCoordinator()?.showError(message: "Something went wrong trying to add new users")
                case.finished:
                    return
                }
            } receiveValue: { [weak self] responseModel in
                guard let room = responseModel.data?.room else { return }
                self?.updateRoom(room: room)
            }.store(in: &self.subscriptions)
    }
    
    func muteUnmute(mute: Bool) {
        self.repository
            .muteUnmuteRoom(roomId: self.room.value.id, mute: mute)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                let roomName = self.room.value.name ?? String(self.room.value.id)

                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.getAppCoordinator()?
                        .showError(message: "Something went wrong \(mute ? "Muting" : "Unmuting") the room \(roomName)")
                    //TODO: Reset Room muted state & observer
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
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
            .updateLocalRoom(room: room )
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
    
    deinit {
//        print("Deinit Works")
    }
    
}
