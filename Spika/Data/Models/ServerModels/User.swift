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
    var avatarFileId: Int64?
    var telephoneNumber: String?
    var telephoneNumberHashed: String?
    var emailAddress: String?
    var createdAt: Int64
    
    var contactsName: String?
        
    init(entity: UserEntity) {
        self.id = entity.id
        self.displayName = entity.displayName
        self.avatarFileId = entity.avatarFileId
        self.telephoneNumber = entity.telephoneNumber
        self.emailAddress = entity.emailAddress
        self.createdAt = entity.createdAt
        
        self.contactsName = entity.contactsName
    }
    
    func getDisplayName() -> String {
        var displayNameResult: String
        
        displayNameResult = contactsName ?? (displayName ?? "no name")
        
        if displayNameResult.isEmpty {
            displayNameResult = displayName ?? "noname"
        }
        
        return displayNameResult
    }
    
    func getAvatarUrl() -> URL? {
         let s = "api/upload/files/" + "\(avatarFileId ?? 0)"
         return s.getFullUrl()
    }
}
