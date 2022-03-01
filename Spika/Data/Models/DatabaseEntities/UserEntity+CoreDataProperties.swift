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

    @NSManaged public var avatarUrl: String?
    @NSManaged public var blocked: Bool
    @NSManaged public var createdAt: Int64
    @NSManaged public var id: Int64
    @NSManaged public var localName: String?
    @NSManaged public var loginName: String?
    @NSManaged public var modifiedAt: Int64
    @NSManaged public var nickName: String?
    @NSManaged public var chats: Set<ChatEntity>?
    @NSManaged public var messages: Set<MessageEntity>?
    @NSManaged public var reactions: Set<ReactionEntity>?
    
    convenience init(insertInto context: NSManagedObjectContext?, user: User) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(user.id ?? -1)
        self.loginName = user.loginName
        self.avatarUrl = user.avatarUrl
        self.localName = user.localName
        self.blocked = user.blocked
        self.createdAt = Int64(user.createdAt ?? 0)
        self.modifiedAt = Int64(user.modifiedAt ?? 0)
        
    }


}

// MARK: Generated accessors for chats
extension UserEntity {

    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: ChatEntity)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: ChatEntity)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)

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

// MARK: Generated accessors for reactions
extension UserEntity {

    @objc(addReactionsObject:)
    @NSManaged public func addToReactions(_ value: ReactionEntity)

    @objc(removeReactionsObject:)
    @NSManaged public func removeFromReactions(_ value: ReactionEntity)

    @objc(addReactions:)
    @NSManaged public func addToReactions(_ values: NSSet)

    @objc(removeReactions:)
    @NSManaged public func removeFromReactions(_ values: NSSet)

}

extension UserEntity : Identifiable {

}
