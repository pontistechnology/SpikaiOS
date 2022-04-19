//
//  ContactEntity+CoreDataClass.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData

@objc(ContactEntity)
public class ContactEntity: NSManagedObject {
    
    convenience init(phoneNumber: String, givenName: String?, familyName: String?, context: NSManagedObjectContext) {
        print("Thread check userentity: " , Thread.current)
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.contactEntity, in: context) else {
            fatalError("fanta")
        }
        self.init(entity: entity, insertInto: context)
        
        self.phoneNumber = phoneNumber
        self.givenName = givenName
        self.familyName = familyName
    }
}
