//
//  User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation

struct User: Codable {
    public var id: Int?
    public var loginName: String?
    public var avatarUrl: String?
    public var localName: String?
    public var blocked: Bool
    public var createdAt: String?
    public var modifiedAt: String?
    
    init(loginName: String, avatarUrl: String? = nil, localName: String, id: Int? = nil, blocked: Bool = false) {
        self.id = id
        self.loginName = loginName
        self.avatarUrl = avatarUrl
        self.localName = localName
        self.blocked = blocked
        self.createdAt = nil
        self.modifiedAt = nil
    }
    
    init(entity: UserEntity) {
        self.id = Int(entity.id)
        self.loginName = entity.loginName
        self.avatarUrl = entity.avatarUrl
        self.localName = entity.localName
        self.blocked = entity.blocked
        self.createdAt = entity.createdAt
        self.modifiedAt = entity.modifiedAt
    }
}
