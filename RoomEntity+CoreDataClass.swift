//
//  RoomEntity+CoreDataClass.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.04.2022..
//
//

import Foundation
import CoreData

@objc(RoomEntity)
public class RoomEntity: NSManagedObject {
    
    convenience init(room: Room, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.roomEntity, in: context) else {
            fatalError("shit, do something")
        }
        self.init(entity: entity, insertInto: context)
        self.id = room.id
        self.name = room.name
        self.avatarUrl = room.avatarUrl
        self.createdAt = room.createdAt
        self.type = room.type.rawValue
        
        for roomUser in room.users { 
            let r = RoomUserEntity(roomUser: roomUser, roomId: room.id, insertInto: context)
            self.addToUsers(r)
        }
    }
}

extension RoomEntity {
    func numberOfUnreadMessages() -> Int{
//        print("visitedRoom is: ", visitedRoom)
        return (messages?.array as! [MessageEntity]).filter{$0.createdAt > visitedRoom}.count
//            && $0.fromUserId != viewModel.getMyUserId()}
    }
    
    func lastMessageText() -> String {
        guard let lastMessage = messages?.lastObject as? MessageEntity else {
            return "No messages"
        }
        if type == RoomType.privateRoom.rawValue {
            return lastMessage.bodyText ?? ""
        } else {
            return ((users?.allObjects as? [RoomUserEntity])?.first(where: {$0.userId == lastMessage.fromUserId})?.user?.contactsName ?? "no name") + ": " + (lastMessage.bodyText ?? "")
        }
    }
    
    func lastMessageTime() -> String {
        return (messages?.lastObject as? MessageEntity)?.createdAt.convert(to: .allChatsTimeFormat) ?? ""
    }
}
