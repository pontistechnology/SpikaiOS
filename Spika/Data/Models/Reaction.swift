//
//  Reaction.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation

struct Reaction: Codable {
    var createdAt: Int?
    var id: Int64
    var modifiedAt: String?
    var type: String?
    var message: Message?
    var user: User?
}
