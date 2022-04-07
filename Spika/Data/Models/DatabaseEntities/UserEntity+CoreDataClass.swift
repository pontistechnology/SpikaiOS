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
    convenience init(user: User) {
        self.init(entity: UserEntityService.entity, insertInto: CoreDataManager.shared.managedContext)
        self.id = user.id
        self.createdAt = user.createdAt ?? 0 // TODO: check
        self.avatarUrl = user.avatarUrl
        self.emailAddress = user.emailAddress
        self.telephoneNumber = user.telephoneNumber
        self.displayName = user.displayName
    }
}
