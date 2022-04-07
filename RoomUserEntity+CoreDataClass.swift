//
//  RoomUserEntity+CoreDataClass.swift
//  Spika
//
//  Created by Nikola Barbarić on 06.04.2022..
//
//

import Foundation
import CoreData

@objc(RoomUserEntity)
public class RoomUserEntity: NSManagedObject {
    convenience init(roomUser: RoomUser) {
        self.init(entity: RoomUserEntityService.entity,
                  insertInto: CoreDataManager.shared.managedContext)
        self.userId = Int64(roomUser.userId)
        self.isAdmin = roomUser.isAdmin
        
        self.user = UserEntity(user: roomUser.user)
    }
}
