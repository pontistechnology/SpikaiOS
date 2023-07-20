//
//  UserEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.04.2022..
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
    }

    @NSManaged public var avatarFileId: Int64
    @NSManaged public var createdAt: Int64
    @NSManaged public var modifiedAt: Int64
    @NSManaged public var displayName: String?
    @NSManaged public var emailAddress: String?
    @NSManaged public var contactsName: String?
    @NSManaged public var id: Int64
    @NSManaged public var telephoneNumber: String?

}

extension UserEntity : Identifiable {

}
