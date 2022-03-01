//
//  ReactionEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData


extension ReactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReactionEntity> {
        return NSFetchRequest<ReactionEntity>(entityName: "ReactionEntity")
    }

    @NSManaged public var createdAt: Int64
    @NSManaged public var id: Int64
    @NSManaged public var modifiedAt: String?
    @NSManaged public var type: String?
    @NSManaged public var message: MessageEntity?
    @NSManaged public var user: UserEntity?

}

extension ReactionEntity : Identifiable {

}
