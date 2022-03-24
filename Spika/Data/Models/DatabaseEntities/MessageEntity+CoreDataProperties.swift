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
    @NSManaged public var reactions: NSSet?
    @NSManaged public var user: UserEntity?
    
    

}

extension MessageEntity : Identifiable {

}
