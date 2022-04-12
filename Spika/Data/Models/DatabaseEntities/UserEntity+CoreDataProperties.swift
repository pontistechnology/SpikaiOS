//
//  UserEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
    
    @NSManaged public var id: Int
    @NSManaged public var displayName: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var telephoneNumber: String?
    @NSManaged public var emailAddress: String?
    @NSManaged public var createdAt: Int
    
    @NSManaged public var givenName: String?
    @NSManaged public var familyName: String?

//    @NSManaged public var avatarUrl: String?
//    @NSManaged public var blocked: Bool
//    @NSManaged public var createdAt: Int64
//    @NSManaged public var id: Int64
//    @NSManaged public var localName: String?
//    @NSManaged public var loginName: String?
//    @NSManaged public var modifiedAt: Int64
//    @NSManaged public var nickName: String?
//    @NSManaged public var chats: Set<ChatEntity>?
//    @NSManaged public var messages: Set<MessageEntity>?
//    @NSManaged public var reactions: Set<ReactionEntity>?
    
    
}


// MARK: Generated accessors for messages
extension UserEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension UserEntity : Identifiable {

}
