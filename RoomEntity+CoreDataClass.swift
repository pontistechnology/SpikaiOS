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
        self.modifiedAt = room.modifiedAt
        self.type = room.type.rawValue
        self.muted = room.muted
        self.roomDeleted = room.deleted
        self.pinned = room.pinned
        self.unreadCount = room.unreadCount
    }
}
