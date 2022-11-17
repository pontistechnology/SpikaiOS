//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import Foundation
import Combine

class ChatDetailsViewModel: BaseViewModel {
 
    var chat: Room
    
    let groupImagePublisher = CurrentValueSubject<URL?,Never>(nil)
    let groupNamePublisher = CurrentValueSubject<String?,Never>(nil)
    
    let isAdmin = CurrentValueSubject<Bool,Never>(false)
    
    let groupContacts = CurrentValueSubject<[RoomUser],Never>([])
    
    init(repository: Repository, coordinator: Coordinator, chat: Room) {
        self.chat = chat
        super.init(repository: repository, coordinator: coordinator)
        self.setupBindings()
        self.updateIsadmin()
    }
    
    func setupBindings() {
        if let avatarUrl = chat.avatarUrl?.getFullUrl() {
            groupImagePublisher.send(avatarUrl)
        }
        
        self.groupNamePublisher.send(chat.name)
        
        self.groupContacts.send(self.chat.users)
    }
    
    func updateIsadmin() {
        let isAdmin = self.chat.users.filter { $0.userId == self.getMyUserId() }.first?.isAdmin ?? false
        self.isAdmin.send(isAdmin)
    }
    
    func muteUnmute(mute: Bool) {
        self.repository
            .muteUnmuteRoom(roomId: chat.id, mute: mute)
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                let roomName = self.chat.name ?? String(self.chat.id)
                
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.getAppCoordinator()?.showError(message: "Something went wrong \(mute ? "Muting" : "Unmuting") the room \(roomName)")
                    //TODO: Reset Room muted state & observer
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func onAddNewUser() {
        let usersSelected = PassthroughSubject<[User],Never>()
        self.getAppCoordinator()?.presentUserSelection(preselectedUsers: chat.users.map { $0.user }, usersSelectedPublisher: usersSelected)
        
        usersSelected
            .sink { [unowned self] users in
                self.updateWithNewUsers(users: users)
            }.store(in: &self.subscriptions)
    }
    
    func updateWithNewUsers(users: [User]) {
        let userIds = chat.users.map { $0.userId } + users.map { $0.id }
        self.repository.updateRoomUsers(roomId: self.chat.id, userIds: userIds)
            .sink { c in
                switch c {
                case .failure(_):
                    self.getAppCoordinator()?.showError(message: "Something went wrong trying to add new users")
                case.finished:
                    return
                }
            } receiveValue: { [weak self] responseModel in
                guard let room = responseModel.data?.room else { return }
                self?.storeRoom(room: room)
                self?.chat = room
                self?.groupContacts.send(room.users)
            }.store(in: &self.subscriptions)
    }
    
    func removeUser(user: User) {
        var userIds = chat.users.map { $0.userId }
        userIds.removeAll(where: { $0 == user.id })
        self.repository.updateRoomUsers(roomId: self.chat.id, userIds: userIds)
            .sink { c in
                switch c {
                case .failure(_):
                    self.getAppCoordinator()?.showError(message: "Something went wrong trying to add new users")
                case.finished:
                    return
                }
            } receiveValue: { [weak self] responseModel in
                guard let room = responseModel.data?.room else { return }
                self?.storeRoom(room: room)
                self?.chat = room
                self?.groupContacts.send(room.users)
            }.store(in: &self.subscriptions)
    }
    
    func storeRoom(room: Room) {
    }
    
}
