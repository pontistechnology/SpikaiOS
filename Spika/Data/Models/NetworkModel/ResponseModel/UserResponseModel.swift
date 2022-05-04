//
//  UserResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

struct UserResponseModel: Codable {
    let status: String?
    let data: UserData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct UserData: Codable {
    let user: User
}
