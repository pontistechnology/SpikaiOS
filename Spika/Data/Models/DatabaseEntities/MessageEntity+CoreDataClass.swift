//
//  MessageEntity+CoreDataClass.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData

@objc(MessageEntity)
public class MessageEntity: NSManagedObject {
    
      // TODO: think about making everything optional before response
    convenience init(message: Message, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageEntity, in: context) else {
            fatalError("Error, init Message entity")
        }
        self.init(entity: entity, insertInto: context)
        
        createdAt = message.createdAt
        createdDate = Date(timeIntervalSince1970: Double(message.createdAt) / 1000)
        
        fromUserId = message.fromUserId
        
        if let id = message.id {
            self.id = "\(id)"
        }
        
        if let localId = message.localId {
            self.localId = localId
        }
        
        if let totalUserCount = message.totalUserCount {
            self.totalUserCount = totalUserCount
        }

        if let deliveredCount = message.deliveredCount {
            self.deliveredCount = deliveredCount
        }

        if let seenCount = message.seenCount {
            self.seenCount = seenCount
        }
        
        roomId = message.roomId

        if let type = message.type {
            self.type = type.rawValue
        }
        
        if let bodyText = message.body?.text {
            self.bodyText = bodyText
        }
        
        if let imagePath = message.body?.file?.path {
            self.imagePath = imagePath
        }
    }
}
