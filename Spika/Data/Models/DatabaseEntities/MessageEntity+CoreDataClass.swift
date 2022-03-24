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
    public convenience init(insertInto context: NSManagedObjectContext?, message: LocalMessage) {
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
        self.user = user
        
    }
}
