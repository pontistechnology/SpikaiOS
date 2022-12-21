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

    @NSManaged public var avatarUrl: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var id: Int64
    @NSManaged public var lastMessageTimestamp: Int64
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var visitedRoom: Int64
    @NSManaged public var muted: Bool
    @NSManaged public var messages: NSOrderedSet?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for messages
extension RoomEntity {

    @objc(insertObject:inMessagesAtIndex:)
    @NSManaged public func insertIntoMessages(_ value: MessageEntity, at idx: Int)

    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged public func removeFromMessages(at idx: Int)

    @objc(insertMessages:atIndexes:)
    @NSManaged public func insertIntoMessages(_ values: [MessageEntity], at indexes: NSIndexSet)

    @objc(removeMessagesAtIndexes:)
    @NSManaged public func removeFromMessages(at indexes: NSIndexSet)

    @objc(replaceObjectInMessagesAtIndex:withObject:)
    @NSManaged public func replaceMessages(at idx: Int, with value: MessageEntity)

    @objc(replaceMessagesAtIndexes:withMessages:)
    @NSManaged public func replaceMessages(at indexes: NSIndexSet, with values: [MessageEntity])

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSOrderedSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSOrderedSet)

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
