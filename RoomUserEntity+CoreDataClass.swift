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
    
    convenience init(roomUser: RoomUser, insertInto context: NSManagedObjectContext) {
        print("Thread check roomuserentity: " , Thread.current)
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.roomUserEntity, in: context) else {
            fatalError("shit, do something")
        }
        self.init(entity: entity, insertInto: context)
        self.userId = Int64(roomUser.userId)
        self.isAdmin = roomUser.isAdmin
        context.perform {
            self.user = UserEntity(user: roomUser.user, context: context)            
        }
    }
}
