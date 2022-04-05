//
//  RoomEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.04.2022..
//
//

import Foundation
import CoreData


extension RoomEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var type: String?
    @NSManaged public var name: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var createdAt: Int64

}

extension RoomEntity : Identifiable {

}
