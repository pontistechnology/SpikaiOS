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
    var modifiedAt: Int64
    
    var contactsName: String?
        
    func getDisplayName() -> String {
        var displayNameResult: String
        
        displayNameResult = contactsName ?? (displayName ?? "no name")
        
        if displayNameResult.isEmpty {
            displayNameResult = displayName ?? "noname"
        }
        
        return displayNameResult.trimmingCharacters(in: .whitespaces)
    }
}

extension User {
    init(entity: UserEntity) {
        self.init(id: entity.id,
                  displayName: entity.displayName,
                  avatarFileId: entity.avatarFileId,
                  telephoneNumber: entity.telephoneNumber,
                  emailAddress: entity.emailAddress,
                  createdAt: entity.createdAt,
                  modifiedAt: entity.modifiedAt,
                  contactsName: entity.contactsName)
    }
}
