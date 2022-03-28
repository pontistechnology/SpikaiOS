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
        
        if seenCount == 0 {
            return .sent
        }
        
//        if receivedCount == totalDeviceCount {
//            return .delivered
//        }
//        
        return .waiting
    }
        
    convenience init(message: Message) {
        self.init(entity: MessageEntityService.entity, insertInto: CoreDataManager.shared.managedContext)
        createdAt = Int64(message.createdAt)
        id = Int64(message.id)
        fromUserId = Int64(message.fromUserId)
        fromDeviceId = Int64(message.fromDeviceId)
        totalDeviceCount = Int64(message.totalDeviceCount)
        receivedCount = Int64(message.receivedCount)
        seenCount = Int64(message.seenCount)
        roomId = Int64(message.roomId)
        type = message.type
        bodyText = message.body.text
    }
}
