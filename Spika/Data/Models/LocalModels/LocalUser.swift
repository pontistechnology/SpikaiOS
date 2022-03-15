//
//  User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation

struct LocalUser: Codable {
    public var id: Int?
    public var loginName: String?
    public var avatarUrl: String?
    public var localName: String?
    public var blocked: Bool
    public var createdAt: Int?
    public var modifiedAt: Int?
    
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
        self.createdAt = Int(entity.createdAt)
        self.modifiedAt = Int(entity.modifiedAt)
    }
    
    func getAvatarUrl() -> String? {
        if let avatarUrl = avatarUrl {
            if avatarUrl.starts(with: "http") {
                return avatarUrl
            } else {
                return Constants.Networking.baseUrl + avatarUrl
            }
        } else {
            return nil
        }
    }
}

extension LocalUser: Comparable {
    static func < (lhs: LocalUser, rhs: LocalUser) -> Bool {
        return lhs.loginName!.localizedStandardCompare(rhs.loginName!) == .orderedAscending
    }
    
    static func == (lhs: LocalUser, rhs: LocalUser) -> Bool {
        return lhs.loginName!.localizedStandardCompare(rhs.loginName!) == .orderedSame
    }
}
