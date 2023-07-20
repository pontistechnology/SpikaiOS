//
//  UserRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

struct UserRequestModel: Codable {
    var telephoneNumber: String?
    var emailAddress: String?
    var displayName: String?
    var avatarFileId: Int64?
}
