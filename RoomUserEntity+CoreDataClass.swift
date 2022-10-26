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
    
    convenience init(roomUser: RoomUser, roomId: Int64, insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.roomUserEntity, in: context) else {
            fatalError("error, MessageRecordEntity")
        }
        self.init(entity: entity, insertInto: context)
        self.userId = roomUser.userId
        self.isAdmin = roomUser.isAdmin ?? false // TODO: check always?
        self.roomId = roomId
        self.user = UserEntity(user: roomUser.user, context: context)
    }
}
