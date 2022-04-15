//
//  MessageEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.04.2022..
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var bodyText: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var fromDeviceId: Int64
    @NSManaged public var fromUserId: Int64
    @NSManaged public var id: Int64
    @NSManaged public var receivedCount: Int64
    @NSManaged public var roomId: Int64
    @NSManaged public var seenCount: Int64
    @NSManaged public var totalDeviceCount: Int64
    @NSManaged public var type: String?

}

extension MessageEntity : Identifiable {

}
