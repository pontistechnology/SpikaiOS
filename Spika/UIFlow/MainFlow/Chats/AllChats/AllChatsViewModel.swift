//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class AllChatsViewModel: BaseViewModel {
    
    let defaultChatsPredicate = NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)' OR messages.@count > 0")
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(user: User) {
        getAppCoordinator()?.presentCurrentChatScreen(user: user)
    }
    
    func presentCurrentChatScreen(room: Room) {
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
}
