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
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context) else {
            fatalError("fanta")
        }
        self.init(entity: entity, insertInto: context)
        self.id = user.id
        self.createdAt = user.createdAt ?? 0 // TODO: check
        self.avatarUrl = user.avatarUrl
        self.emailAddress = user.emailAddress
        self.telephoneNumber = user.telephoneNumber
        self.displayName = user.displayName
        
        self.givenName = user.givenName
        self.familyName = user.familyName
    }
    
    convenience init(insertInto context: NSManagedObjectContext?, user: User) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = user.id
        self.displayName = user.displayName
        self.avatarUrl = user.avatarUrl
        self.telephoneNumber = user.telephoneNumber
        self.emailAddress = user.emailAddress
        self.createdAt = user.createdAt!
        
        self.givenName = user.givenName
        self.familyName = user.familyName
    }
    
    func getDisplayName() -> String {
        var displayNameResult: String
        
        displayNameResult = [givenName, familyName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        
        if displayNameResult.isEmpty {
            displayNameResult = displayName ?? "noname"
        }
        
        return displayNameResult
    }
}
