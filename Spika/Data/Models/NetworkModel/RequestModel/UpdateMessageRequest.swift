//
//  EditMessageRequest.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.05.2023..
//

import Foundation

struct UpdateMessageRequest: Codable {
    let id: Int64
    let text: String
}
