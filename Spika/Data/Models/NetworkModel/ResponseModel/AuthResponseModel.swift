//
//  AuthRequestModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation

// MARK: - AuthResponseModel
struct AuthResponseModel: Codable {
    let status: String?
    let data: AuthData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct AuthData: Codable {
    let isNewUser: Bool?
    let user: User?
    let device: Device?
}

// MARK: - Device
struct Device: Codable {
    let id: Int?
    let userId: Int?
    let token: String?
    let tokenExpiredAt: Int?
    let osName: String?
    let osVersion: String?
    let appVersion: Int?
    let pushToken: String?
}
