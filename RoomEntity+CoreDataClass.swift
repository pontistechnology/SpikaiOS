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
        self.id = Int64(room.id)
        self.name = room.name
        self.avatarUrl = room.avatarUrl
        self.createdAt = Int64(room.createdAt!)
        self.type = room.type
        
        for roomUser in room.users! { // TODO: check
            let r = RoomUserEntity(roomUser: roomUser, insertInto: context)
            self.addToUsers(r)
        }
    }
}
