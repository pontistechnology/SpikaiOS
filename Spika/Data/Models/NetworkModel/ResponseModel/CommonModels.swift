//
//  CommonModels.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

// MARK: - User
struct AppUser: Codable {
    let id: Int?
    let displayName: String?
    let avatarUrl: String?
    let telephoneNumber: String?
    let telephoneNumberHashed: String?
    let emailAddress: String?
    let createdAt: String?
}
