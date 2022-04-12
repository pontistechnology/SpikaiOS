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
    
    convenience init(room: Room) {
        self.init(entity: RoomEntityService.entity, insertInto: CoreDataManager.shared.managedContext)
        self.id = Int64(room.id)
        self.name = room.name
        self.avatarUrl = room.avatarUrl
        self.createdAt = Int64(room.createdAt)
        self.type = room.type
        
        for roomUser in room.users {
//            let r = RoomUserEntity(roomUser: roomUser)
//            self.addToUsers(r)
        }
    }
}
