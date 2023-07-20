//
//  RoomUserEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.06.2022..
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
    @NSManaged public var roomId: Int64

}

extension RoomUserEntity : Identifiable {

}
