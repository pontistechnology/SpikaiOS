//
//  UserEntity+CoreDataClass.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {
    
    convenience init(user: User, context: NSManagedObjectContext) {
        print("Thread check userentity: " , Thread.current)
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context) else {
            fatalError("fanta")
        }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(user.id)
        self.createdAt = Int64(user.createdAt ?? 0) // TODO: check
        self.avatarUrl = user.avatarUrl
        self.emailAddress = user.emailAddress
        self.telephoneNumber = user.telephoneNumber
        self.displayName = user.displayName
    }
    
    convenience init(insertInto context: NSManagedObjectContext?, user: LocalUser) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(user.id)
        self.displayName = user.displayName
        self.avatarUrl = user.avatarUrl
        self.telephoneNumber = user.telephoneNumber
        self.emailAddress = user.emailAddress
        self.createdAt = Int64(user.createdAt!)
        
        self.givenName = user.givenName
        self.familyName = user.familyName
    }
}
