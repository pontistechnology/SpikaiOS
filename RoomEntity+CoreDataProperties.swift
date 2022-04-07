//
//  RoomEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 06.04.2022..
//
//

import Foundation
import CoreData


extension RoomEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for users
extension RoomEntity {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: RoomUserEntity)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: RoomUserEntity)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension RoomEntity : Identifiable {

}
