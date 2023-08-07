//
//  AllNotesResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation

struct AllNotesResponseModel: Codable {
    let status: String?
    let data: AllNotesData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct AllNotesData: Codable {
    let notes: [Note]?
}

struct Note: Codable {
    let id: Int64
    let title: String
    let content: String
    let roomId: Int64
    let createdAt: Int64
    let modifiedAt: Int64?
}
