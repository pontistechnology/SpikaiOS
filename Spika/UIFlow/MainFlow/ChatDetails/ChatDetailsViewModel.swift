//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit
import Combine

class ChatDetailsViewModel: BaseViewModel {
 
    var chat: Room
    
    let groupImagePublisher = CurrentValueSubject<URL?,Never>(nil)
    let groupNamePublisher = CurrentValueSubject<String?,Never>(nil)
    
    let isAdmin = CurrentValueSubject<Bool,Never>(false)
    
    let groupContacts = CurrentValueSubject<[RoomUser],Never>([])
    
    private let updateContacts = PassthroughSubject<[Int64],Never>()
    
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
        
        self.updateContacts
            .flatMap { [weak self] userIds in
                guard let `self` = self else {
                    return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken).eraseToAnyPublisher()
                }
                return self.repository.updateRoomUsers(roomId: self.chat.id, userIds: userIds)
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
                    self.getAppCoordinator()?
                        .showError(message: "Something went wrong \(mute ? "Muting" : "Unmuting") the room \(roomName)")
                    //TODO: Reset Room muted state & observer
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func onAddNewUser() {
        let usersSelected = PassthroughSubject<[User],Never>()
        self.getAppCoordinator()?.presentUserSelection(preselectedUsers: chat.users.map { $0.user }, usersSelectedPublisher: usersSelected)
        
        usersSelected
            .map { [unowned self] newUsers in
                return self.chat.users.map { $0.userId } + newUsers.map { $0.id }
            }
            .subscribe(self.updateContacts)
            .store(in: &self.subscriptions)
    }
    
    func removeUser(user: User) {
        var userIds = chat.users.map { $0.userId }
        userIds.removeAll(where: { $0 == user.id })
        self.updateContacts.send(userIds)
    }
    
    func updateRoom(room: Room) {
        self.chat = room
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
            } receiveValue: { room in

            }.store(in: &self.subscriptions)

        self.groupContacts.send(room.users)
    }
    
    deinit {
        print("Deinit Works")
    }
    
}
