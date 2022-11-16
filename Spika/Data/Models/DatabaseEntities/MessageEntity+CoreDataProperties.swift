//
//  MessageEntity+CoreDataProperties.swift
//  
//
//  Created by Nikola Barbarić on 28.09.2022..
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
    @NSManaged public var deliveredCount: Int64
    @NSManaged public var fromUserId: Int64
    @NSManaged public var id: String?
    @NSManaged public var filePath: String?
    @NSManaged public var localId: String?
    @NSManaged public var roomId: Int64
    @NSManaged public var seenCount: Int64
    @NSManaged public var totalUserCount: Int64
    @NSManaged public var type: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var records: NSSet?
    @NSManaged public var room: RoomEntity?
    
    @objc public var sectionName: String {
        guard let createdDate = createdDate else {
            return ""
        }
        let dateFormatter = DateFormatter()
        if createdDate.isInToday {
            return "Today"
        } else if createdDate.isInYesterday {
            return "Yesterday"
        } else if createdDate.isInThisWeek {
            dateFormatter.dateFormat = "EEEE"
        }
        else if createdDate.isInThisYear {
            dateFormatter.dateFormat = "dd MM"
        } else {
            dateFormatter.dateFormat = "dd MM YYYY"
        }
        return dateFormatter.string(from: createdDate)
    }
}

// MARK: Generated accessors for records
extension MessageEntity {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: MessageRecordEntity)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: MessageRecordEntity)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}
