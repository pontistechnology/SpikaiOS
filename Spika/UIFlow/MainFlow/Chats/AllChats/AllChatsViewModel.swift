//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine

class AllChatsViewModel: BaseViewModel {
    
    var defaultChatsPredicate: NSPredicate = {
        let predicate1 =  NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)'") // TODO: - add message count greater than 0
        let predicate2 = NSPredicate(format: "roomDeleted = false")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
    } ()
    
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
