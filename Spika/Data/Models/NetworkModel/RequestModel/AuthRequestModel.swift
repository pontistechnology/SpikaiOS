//
//  AuthRequestModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation

struct AuthRequestModel: Codable {
    let telephoneNumber: String
    let telephoneNumberHashed: String
    let deviceId: String
}
