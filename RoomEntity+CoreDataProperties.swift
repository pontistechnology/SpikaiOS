//
//  RoomEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.06.2022..
//
//

import Foundation
import CoreData


extension RoomEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }

    @NSManaged public var avatarFileId: Int64
    @NSManaged public var createdAt: Int64
    @NSManaged public var id: Int64
    @NSManaged public var lastMessageTimestamp: Int64
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var visitedRoom: Int64
    @NSManaged public var muted: Bool
    @NSManaged public var roomDeleted: Bool
    @NSManaged public var pinned: Bool
    @NSManaged public var unreadCount: Int64
}

extension RoomEntity : Identifiable {

}
