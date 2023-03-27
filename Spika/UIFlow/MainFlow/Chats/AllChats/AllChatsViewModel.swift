//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine
import CoreData

class AllChatsViewModel: BaseViewModel {
    
    var frc: NSFetchedResultsController<RoomEntity>?
    
    var defaultChatsPredicate: NSPredicate = {
        let predicate1 =  NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)'") // TODO: - add message count greater than 0
        let predicate2 = NSPredicate(format: "roomDeleted = false")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
    } ()
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(room: Room) {
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
}

extension AllChatsViewModel {
    func setRoomsFetch() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = self.defaultChatsPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
            // TODO: handle error and change main context to func
        }
    }
    
    func changePredicate(to newString: String) {
        let searchPredicate = newString.isEmpty ? defaultChatsPredicate : NSPredicate(format: "name CONTAINS[c] '\(newString)' and roomDeleted = false")
        self.frc?.fetchRequest.predicate = searchPredicate
        self.frc?.fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                                  NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                                  NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        try? frc?.performFetch()
    }
    
    func getRoom(for indexPath: IndexPath) -> Room? {
        guard let entity = frc?.object(at: indexPath),
              let roomUsers = repository.getRoomUsers(roomId: entity.id)
        else { return nil }
        return Room(roomEntity: entity, users: roomUsers)
    }
    
    func description(message: Message?, room: Room) -> String {
        guard let message = message else { return "(No messages)"}
        let desc: String
        if room.type == .privateRoom {
            desc = (message.fromUserId == getMyUserId() ? "Me: " : "")
            + (message.body?.text ?? message.type.pushNotificationText)
        } else {
            desc = (message.fromUserId == getMyUserId() ? "Me: " : ((room.users.first(where: { $0.userId == message.fromUserId })?.user.getDisplayName() ?? "_")))
                    + ": " + (message.body?.text ?? message.type.pushNotificationText)
        }
        return desc
    }
}
