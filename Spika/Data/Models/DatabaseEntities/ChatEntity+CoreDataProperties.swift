//
//  ChatEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData


extension ChatEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatEntity> {
        return NSFetchRequest<ChatEntity>(entityName: "ChatEntity")
    }

    @NSManaged public var createdAt: String?
    @NSManaged public var groupUrl: String?
    @NSManaged public var id: Int64
    @NSManaged public var modifiedAt: String?
    @NSManaged public var muted: Bool
    @NSManaged public var name: String?
    @NSManaged public var pinned: Bool
    @NSManaged public var type: String?
    @NSManaged public var typing: String?
    @NSManaged public var messages: Set<MessageEntity>?
    @NSManaged public var users: Set<UserEntity>?
    
    convenience init(insertInto context: NSManagedObjectContext?, chat: Chat) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.chatEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)

        self.id = Int64(chat.id)
        self.name = chat.name
        self.groupUrl = chat.groupUrl
        self.type = chat.type
        self.typing = chat.typing
        self.muted = chat.muted
        self.pinned = chat.pinned
        self.createdAt = chat.createdAt
        self.modifiedAt = chat.modifiedAt
    }

}

// MARK: Generated accessors for messages
extension ChatEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

// MARK: Generated accessors for users
extension ChatEntity {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: UserEntity)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: UserEntity)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension ChatEntity : Identifiable {

}
