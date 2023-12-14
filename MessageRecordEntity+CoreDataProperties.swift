//
//  MessageRecordEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.05.2022..
//
//

import Foundation
import CoreData


extension MessageRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageRecordEntity> {
        return NSFetchRequest<MessageRecordEntity>(entityName: "MessageRecordEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var type: String?
    @NSManaged public var messageId: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var createdAt: Int64
    @NSManaged public var modifiedAt: Int64
    @NSManaged public var reaction: String?
    @NSManaged public var isRemoved: Bool
}

extension MessageRecordEntity : Identifiable {

}
