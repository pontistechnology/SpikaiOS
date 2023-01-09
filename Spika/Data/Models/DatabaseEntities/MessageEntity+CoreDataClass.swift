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

        self.type = message.type.rawValue
        
        if let bodyText = message.body?.text {
            self.bodyText = bodyText
        }
        
        if let fileId = message.body?.file?.id {
            self.bodyFileId = fileId
        }
        
        if let fileMimeType = message.body?.file?.mimeType {
            self.bodyFileMimeType = fileMimeType
        }
        
        if let fileSize = message.body?.file?.size {
            self.bodyFileSize = fileSize
        }
        
        if let fileName = message.body?.file?.fileName {
            self.bodyFileName = fileName
        }
        
        
        self.replyId = "\(message.replyId ?? -1)"
        
        
        if let thumbId = message.body?.thumb?.id {
            self.bodyThumbId = thumbId
        }
        
        if let thumbMimeType = message.body?.thumb?.mimeType {
            self.bodyThumbMimeType = thumbMimeType
        }
        
        if let thumbWidth = message.body?.thumb?.metaData?.width {
            self.bodyThumbMetaDataWidth = thumbWidth
        }
        
        if let thumbHeight = message.body?.thumb?.metaData?.height {
            self.bodyThumbMetaDataHeight = thumbHeight
        }
        
        if let thumbDuration = message.body?.thumb?.metaData?.duration {
            self.bodyThumbMetaDataDuration = thumbDuration
        }
        
        if let fileWidth = message.body?.file?.metaData?.width {
            self.bodyFileMetaDataWidth = fileWidth
        }
        
        if let fileHeight = message.body?.file?.metaData?.height {
            self.bodyFileMetaDataHeight = fileHeight
        }
        
        if let fileDuration = message.body?.file?.metaData?.duration {
            self.bodyFileMetaDataDuration = fileDuration
        }
    }
}
