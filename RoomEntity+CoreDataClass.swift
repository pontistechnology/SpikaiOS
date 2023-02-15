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
            fatalError("error, MessageRecordEntity")
        }
        self.init(entity: entity, insertInto: context)
        self.id = room.id
        self.name = room.name
        self.avatarFileId = room.avatarFileId ?? 0
        self.createdAt = room.createdAt
        self.type = room.type.rawValue
        self.muted = room.muted
        self.roomDeleted = room.deleted
        self.pinned = room.pinned
        
        for roomUser in room.users {
            let r = RoomUserEntity(roomUser: roomUser, roomId: room.id, insertInto: context)
            self.addToUsers(r)
        }
    }
}

extension RoomEntity {
    func numberOfUnreadMessages(myUserId: Int64) -> Int{
        return (messages?.array as? [MessageEntity])?
            .filter { messageEntity in
                messageEntity.createdAt > visitedRoom }
            .filter { newMessages in
                newMessages.fromUserId != myUserId
            }.count ?? 0
    }
    
    func lastMessageText() -> String {
        guard let lastMessage = messages?.lastObject as? MessageEntity else {
            return "No messages"
        }
        if type == RoomType.privateRoom.rawValue {
            return lastMessage.bodyText ?? MessageType(rawValue: lastMessage.type ?? "")?.pushNotificationText ?? ""
        } else {
            return ((users?.allObjects as? [RoomUserEntity])?.first(where: {$0.userId == lastMessage.fromUserId})?.user?.contactsName ?? "no name") + ": " + (lastMessage.bodyText ?? MessageType(rawValue: lastMessage.type ?? "")?.pushNotificationText ?? "")
        }
    }
    
    func lastMessageTime() -> String {
        return (messages?.lastObject as? MessageEntity)?.createdAt.convert(to: .allChatsTimeFormat) ?? ""
    }
}
