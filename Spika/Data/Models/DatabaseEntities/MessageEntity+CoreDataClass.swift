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
        
//        if deliveredCount == totalDeviceCount {
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
        
        if let c = message.createdAt {
            createdAt = Int64(c)
        }
        
        if let fromUserId = message.fromUserId {
            self.fromUserId = Int64(fromUserId)
        }
//        createdAt = Int64(message.createdAt)
        id = Int64(message.id ?? 999999)
//        fromUserId = Int64(message.fromUserId ?? 999999)
        fromDeviceId = Int64(message.fromDeviceId  ?? 1234512)
        totalDeviceCount = Int64(message.totalDeviceCount ?? 1234512)
        deliveredCount = Int64(message.deliveredCount ?? -1)
        seenCount = Int64(message.seenCount ?? 1234512)
        roomId = Int64(message.roomId ?? 1234512)
        type = message.type
        bodyText = message.body!.text
    }
}
