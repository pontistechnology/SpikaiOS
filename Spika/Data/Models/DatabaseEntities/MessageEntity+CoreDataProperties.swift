//
//  MessageEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var createdAt: Int64
    @NSManaged public var fileMimeType: String?
    @NSManaged public var filePath: String?
    @NSManaged public var fromDeviceType: String?
    @NSManaged public var id: Int64
    @NSManaged public var message: String?
    @NSManaged public var messageType: String?
    @NSManaged public var modifiedAt: Int64
    @NSManaged public var replyMessageId: Int64
    @NSManaged public var state: String?
    @NSManaged public var toDeviceType: String?
    @NSManaged public var chat: ChatEntity?
    @NSManaged public var reactions: NSSet?
    @NSManaged public var user: UserEntity?
    
    public convenience init(insertInto context: NSManagedObjectContext?, message: Message) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(message.id)
        self.fileMimeType = message.fileMimeType
        self.filePath = message.filePath
        self.fromDeviceType = message.fromDeviceType
        self.message = message.message
        self.messageType = message.messageType
        self.replyMessageId = message.replyMessageId ?? -1
        self.state = message.state
        self.toDeviceType = message.toDeviceType
        self.createdAt = Int64(message.createdAt ?? 0)
        self.modifiedAt = Int64(message.modifiedAt ?? 0)
        self.chat = chat
        self.user = user
        
    }

}

// MARK: Generated accessors for reactions
extension MessageEntity {

    @objc(addReactionsObject:)
    @NSManaged public func addToReactions(_ value: ReactionEntity)

    @objc(removeReactionsObject:)
    @NSManaged public func removeFromReactions(_ value: ReactionEntity)

    @objc(addReactions:)
    @NSManaged public func addToReactions(_ values: NSSet)

    @objc(removeReactions:)
    @NSManaged public func removeFromReactions(_ values: NSSet)

}

extension MessageEntity : Identifiable {

}
