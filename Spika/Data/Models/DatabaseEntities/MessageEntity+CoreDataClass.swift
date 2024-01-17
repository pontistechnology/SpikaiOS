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
        
        modifiedAt = message.modifiedAt
        fromUserId = message.fromUserId
        dummyValue = 1 // change this when frc needs to see changes
        
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
        
        isRemoved = message.deleted
        isForwarded = message.isForwarded
        
        roomId = message.roomId

        self.type = message.type.rawValue
        
        if let bodyText = message.body?.text {
            self.bodyText = bodyText.replacingOccurrences(of: "\0", with: "")
            // current bug, when text is copied from bad pdf, null character can be included in string, and label will be truncated
        }
        
        if let fileId = message.body?.file?.id {
            self.bodyFileId = "\(fileId)"
        }
        
        if let thumbId = message.body?.thumb?.id {
            self.bodyThumbId = "\(thumbId)"
        }

        self.replyId = "\(message.replyId ?? -1)"
        
        if let bodyType = message.body?.type?.rawValue {
            self.bodyType = bodyType
        }
        
        if let bodySubject = message.body?.subject {
            self.bodySubject = bodySubject
        }
        
        if let bodySubjectIdInt = message.body?.subjectId {
            self.bodySubjectId = String(bodySubjectIdInt)
        }
        
        if let bodyObjects = message.body?.objects {
            self.bodyObjects = bodyObjects
        }
        
        if let bodyObjectIds = message.body?.objectIds {
            self.bodyObjectIds = bodyObjectIds
        }
    }
}
