//
//  UserEntity.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var loginName: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var localName: String?
    @NSManaged public var blocked: Bool
    @NSManaged public var createdAt: String?
    @NSManaged public var modifiedAt: String?
    
    convenience init(insertInto context: NSManagedObjectContext?, user: User) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.userEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(user.id ?? -1)
        self.loginName = user.loginName
        self.avatarUrl = user.avatarUrl
        self.localName = user.localName
        self.blocked = user.blocked
        self.createdAt = user.createdAt
        self.modifiedAt = user.modifiedAt
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: Constants.Database.userEntity)
    }
    
}
