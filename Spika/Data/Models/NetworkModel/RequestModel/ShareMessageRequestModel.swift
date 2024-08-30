//
//  ShareMessageRequestModel.swift
//  Share Extension
//
//  Created by Nikola Barbarić on 23.08.2024..
//

import Foundation

struct ShareMessageRequestModel: Codable {
    let roomIds: [Int64]
    let messages: [ShareMessageaaa]
    let userIds: [Int64]
}

struct ShareMessageaaa: Codable {
    let type: String
    let body: RequestMessageBody
}
