//
//  RoomUserEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.04.2022..
//
//

import Foundation
import CoreData


extension RoomUserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomUserEntity> {
        return NSFetchRequest<RoomUserEntity>(entityName: "RoomUserEntity")
    }

    @NSManaged public var isAdmin: Bool
    @NSManaged public var userId: Int64
    @NSManaged public var user: UserEntity?
    @NSManaged public var inRooms: RoomEntity?

}

extension RoomUserEntity : Identifiable {

}
