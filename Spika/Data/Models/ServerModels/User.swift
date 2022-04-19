//
//  CommonModels.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

// MARK: - User
struct User: Codable {
    let id: Int
    var displayName: String?
    var avatarUrl: String?
    var telephoneNumber: String?
    var telephoneNumberHashed: String?
    var emailAddress: String?
    var createdAt: Int?
    
    var givenName: String?
    var familyName: String?
    
    init(id: Int, displayName: String, avatarUrl: String? = nil) {
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
    }
    
    func getDisplayName() -> String {
        var displayNameResult: String
        
        displayNameResult = [givenName, familyName] // TODO display real names
            .compactMap { $0 }
            .joined(separator: " ")

        
        if displayNameResult.isEmpty {
            displayNameResult = displayName ?? "noname"
        }
        
        return displayNameResult
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

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.displayName!.localizedStandardCompare(rhs.displayName!) == .orderedAscending
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.displayName!.localizedStandardCompare(rhs.displayName!) == .orderedSame
    }
}


