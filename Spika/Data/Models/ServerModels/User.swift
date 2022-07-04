//
//  CommonModels.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

// MARK: - User
struct User: Codable {
    let id: Int64
    var displayName: String?
    var avatarUrl: String?
    var telephoneNumber: String?
    var telephoneNumberHashed: String?
    var emailAddress: String?
    var createdAt: Int64?
    
    var givenName: String?
    var familyName: String?
    
    init(id: Int64, displayName: String, avatarUrl: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.avatarUrl = avatarUrl
    }
    
    init?(entity: UserEntity?) {
        guard let entity = entity else {
            return nil
        }
        self.id = entity.id
        self.displayName = entity.displayName
        self.avatarUrl = entity.avatarUrl
        self.telephoneNumber = entity.telephoneNumber
        self.emailAddress = entity.emailAddress
        self.createdAt = entity.createdAt
        
        self.givenName = entity.givenName
        self.familyName = entity.familyName
    }
    
    func getDisplayName() -> String {
        var displayNameResult: String
        
        displayNameResult = [givenName, familyName] // TODO display real names
            .compactMap{ $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        
        if displayNameResult.isEmpty {
            displayNameResult = displayName ?? "noname"
        }
        
        return displayNameResult
    }
    
    func getAvatarUrl() -> String? {
        if let avatarUrl = avatarUrl {
            if avatarUrl.starts(with: "http") {
                return avatarUrl
            } else if avatarUrl.starts(with: "/") {
                return Constants.Networking.baseUrl + avatarUrl.dropFirst()
            } else {
                return Constants.Networking.baseUrl + avatarUrl
            }
        } else {
            return nil
        }
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.getDisplayName().localizedCaseInsensitiveCompare(rhs.getDisplayName()) == .orderedAscending
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.getDisplayName().localizedCaseInsensitiveCompare(rhs.getDisplayName()) == .orderedSame
    }
}


