//
//  VerifyFileResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.04.2022..
//

import Foundation

struct VerifyFileResponseModel: Codable {
    let status: String?
    let data: VerifyFileData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct VerifyFileData: Codable {
    let file: File?
}

// MARK: - File
struct File: Codable {
    let id: Int?
    let type: String?
    let relationId: Int?
    let path: String?
    let mimeType: String?
    let fileName: String?
    let size: Int?
    let clientId: String?
    let createdAt: Int?
    let modifiedAt: Int?
}
