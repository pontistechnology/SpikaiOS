//
//  Reaction.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation

struct LocalReaction: Codable {
    var createdAt: Int?
    var id: Int64
    var modifiedAt: String?
    var type: String?
    var message: LocalMessage?
    var user: LocalUser?
}
