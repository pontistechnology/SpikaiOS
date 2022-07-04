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
    let id: Int64?
    let userId: Int64?
    let token: String?
    let tokenExpiredAt: Int64?
    let osName: String?
    let osVersion: String?
    let appVersion: String?
    let pushToken: String?
}
