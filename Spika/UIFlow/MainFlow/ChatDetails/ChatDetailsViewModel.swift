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
    
    let groupImagePublisher = CurrentValueSubject<String?,Never>(nil)
    let groupNamePublisher = CurrentValueSubject<String?,Never>(nil)
    
    let groupContacts = CurrentValueSubject<[RoomUser],Never>([])
    
    init(repository: Repository, coordinator: Coordinator, chat: Room) {
        self.chat = chat
        super.init(repository: repository, coordinator: coordinator)
        self.setupBindings()
    }
    
    func setupBindings() {
        if let avatarUrl = chat.getAvatarUrl() {
            groupImagePublisher.send(avatarUrl)
        }
        
        self.groupNamePublisher.send(chat.name)
        
        self.groupContacts.send(self.chat.users)
    }
    
}
