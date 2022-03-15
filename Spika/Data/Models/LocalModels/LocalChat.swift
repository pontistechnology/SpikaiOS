//
//  Chat.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation

struct LocalChat: Codable {
    public var id: Int64
    public var name: String?
    public var groupUrl: String?
    public var type: String?
    public var typing: String?
    public var muted: Bool
    public var pinned: Bool
    public var createdAt: Int?
    public var modifiedAt: Int?
    
    init(name: String, groupUrl: String? = nil, pinned: Bool = false, id: Int? = nil, muted: Bool = false, type: String) {
        self.id = Int64(id ?? -1)
        self.name = name
        self.groupUrl = groupUrl
        self.type = type
        self.typing = nil
        self.muted = muted
        self.pinned = pinned
        self.createdAt = nil
        self.modifiedAt = nil
    }
    
    init(entity: ChatEntity) {
        self.id = Int64(entity.id)
        self.name = entity.name
        self.groupUrl = entity.groupUrl
        self.type = entity.type
        self.typing = entity.typing
        self.muted = entity.muted
        self.pinned = entity.pinned
        self.createdAt = Int(entity.createdAt)
        self.modifiedAt = Int(entity.modifiedAt)
    }
}
