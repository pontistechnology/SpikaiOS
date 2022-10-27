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
            fatalError("Error, MessageRecordEntity")
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = record.id
        self.createdAt = record.createdAt
        self.messageId = record.messageId
        self.userId = record.userId
        
        if let type = record.type {
            self.type = type
        }
        
        if let reaction = record.reaction {
            self.reaction = reaction
        }
        
        if let modifiedAt = record.modifiedAt {
            self.modifiedAt = modifiedAt
        }
    }
}
