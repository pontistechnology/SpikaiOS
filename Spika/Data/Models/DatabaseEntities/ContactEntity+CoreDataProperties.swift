//
//  ContactEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.04.2022..
//
//

import Foundation
import CoreData

extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: Constants.Database.contactEntity)
    }

    @NSManaged public var phoneNumber: String
    @NSManaged public var givenName: String?
    @NSManaged public var familyName: String?
}

extension ContactEntity : Identifiable {

}
