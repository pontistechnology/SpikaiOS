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
    
    func getMessageState() -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        if seenCount == 0 {
            return .sent
        }
        
//        if receivedCount == totalDeviceCount {
//            return .delivered
//        }
//        
        return .waiting
    }
      // TODO: think about making everything optional before response
    convenience init(message: Message, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.messageEntity, in: context) else {
            fatalError("shit, do something")
        }
        self.init(entity: entity, insertInto: context)
        
        createdAt = Int64(message.createdAt)
        id = Int64(message.id)
        fromUserId = Int64(message.fromUserId)
        fromDeviceId = Int64(message.fromDeviceId)
        totalDeviceCount = Int64(message.totalDeviceCount)
        receivedCount = Int64(message.receivedCount ?? -1)
        seenCount = Int64(message.seenCount)
        roomId = Int64(message.roomId)
        type = message.type
        bodyText = message.body.text
    }
}
