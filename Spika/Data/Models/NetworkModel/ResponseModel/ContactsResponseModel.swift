//
//  AuthRequestModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation

// MARK: - AuthResponseModel
struct ContactsResponseModel: Codable {
    let status: String?
    let data: ContactsData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct ContactsData: Codable {
    let list: [User]?
    let limit: Int?
    let count: Int?
}
