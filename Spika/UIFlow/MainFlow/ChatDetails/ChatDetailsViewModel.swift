//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import Foundation
import Combine

class ChatDetailsViewModel: BaseViewModel {
 
    let chat: Room
    
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
            .sink { users in
                print("")
            }.store(in: &self.subscriptions)
    }
    
}
