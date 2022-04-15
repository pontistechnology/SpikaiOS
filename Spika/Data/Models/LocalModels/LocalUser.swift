//
//  User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation

struct LocalUser: Codable {
    public var id: Int
    public var displayName: String?
    public var avatarUrl: String?
    public var telephoneNumber: String?
    public var emailAddress: String?
    public var createdAt: Int?
    
    public var givenName: String?
    public var familyName: String?
    
//    public var id: Int?
//    public var loginName: String?
//    public var avatarUrl: String?
//    public var localName: String?
//    public var blocked: Bool
//    public var createdAt: Int?
//    public var modifiedAt: Int?
    
    init(displayName: String, avatarUrl: String? = nil, id: Int) {
        self.id = id
        self.displayName = displayName
        self.avatarUrl = avatarUrl
    }
    
    init(entity: UserEntity) {
        self.id = Int(entity.id)
        self.displayName = entity.displayName
        self.avatarUrl = entity.avatarUrl
        self.telephoneNumber = entity.telephoneNumber
        self.emailAddress = entity.emailAddress
        self.createdAt = Int(entity.createdAt)
        
        self.givenName = entity.givenName
        self.familyName = entity.familyName
        
//        self.id = Int(entity.id)
//        self.loginName = entity.loginName
//        self.avatarUrl = entity.avatarUrl
//        self.localName = entity.localName
//        self.blocked = entity.blocked
//        self.createdAt = Int(entity.createdAt)
//        self.modifiedAt = Int(entity.modifiedAt)
    }
    
    init(user: User) {
        self.id = user.id
        self.displayName = user.displayName
        self.avatarUrl = user.avatarUrl
        self.telephoneNumber = user.telephoneNumber
        self.emailAddress = user.emailAddress
        self.createdAt = user.createdAt
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
        return lhs.displayName!.localizedStandardCompare(rhs.displayName!) == .orderedAscending
    }
    
    static func == (lhs: LocalUser, rhs: LocalUser) -> Bool {
        return lhs.displayName!.localizedStandardCompare(rhs.displayName!) == .orderedSame
    }
}
