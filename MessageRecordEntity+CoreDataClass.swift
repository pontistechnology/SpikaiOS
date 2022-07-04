//
//  MessageRecordEntity+CoreDataClass.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.05.2022..
//
//

import Foundation
import CoreData

@objc(MessageRecordEntity)
public class MessageRecordEntity: NSManagedObject {
    
    convenience init(record: MessageRecord, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageRecordEntity, in: context) else {
            fatalError("shit, do something")
        }
        self.init(entity: entity, insertInto: context)
        
        if let id = record.id {
            self.id = id
        }
        
        if let messageId = record.messageId {
            self.messageId = messageId
        }
        
        if let userId = record.userId {
            self.userId = userId
        }
        
        if let type = record.type {
            self.type = type
        }
        
        if let reaction = record.reaction {
            self.reaction = reaction
        }
        
        if let modifiedAt = record.modifiedAt {
            self.modifiedAt = modifiedAt
        }
        
        if let createdAt = record.createdAt {
            self.createdAt = createdAt
        }
    }
}
