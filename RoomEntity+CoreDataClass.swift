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
        self.createdAt = room.createdAt!
        self.type = room.type
        
        for roomUser in room.users! { // TODO: check
            let r = RoomUserEntity(roomUser: roomUser, roomId: room.id, insertInto: context)
            self.addToUsers(r)
        }
    }
}
