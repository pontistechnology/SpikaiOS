//
//  AuthRequestModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation

struct AuthResponseModel: Codable {
    let newUser: Bool?
    let user: AppUser
    let device: Device
}

struct AppUser: Codable {
    let id: Int
    let telephoneNumber: String
    let createdAt: String?
    let modifiedAt: String?
}

struct Device: Codable {
    let id: Int
    let userId: Int?
    let deviceId: String?
    let type: String?
    let osName: String?
    let appVersion: String?
    let token: String?
    let pushToken: String?
    let tokenExpiredAt: String?
    let createdAt: String?
    let modifiedAt: String?
}
