//
//  ChatEntity.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import CoreData

@objc(ChatEntity)
public class ChatEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var groupUrl: String?
    @NSManaged public var type: String?
    @NSManaged public var typing: String?
    @NSManaged public var muted: Bool
    @NSManaged public var pinned: Bool
    @NSManaged public var createdAt: String?
    @NSManaged public var modifiedAt: String?
    
    convenience init(insertInto context: NSManagedObjectContext?, chat: Chat) {
        guard let context = context,
            let entity = NSEntityDescription.entity(forEntityName: Constants.Database.chatEntity, in: context)
        else {
            self.init()
            return
        }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(chat.id)
        self.name = chat.name
        self.groupUrl = chat.groupUrl
        self.type = chat.type
        self.typing = chat.typing
        self.muted = chat.muted
        self.pinned = chat.pinned
        self.createdAt = chat.createdAt
        self.modifiedAt = chat.modifiedAt
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatEntity> {
        return NSFetchRequest<ChatEntity>(entityName: Constants.Database.chatEntity)
    }
    
}

