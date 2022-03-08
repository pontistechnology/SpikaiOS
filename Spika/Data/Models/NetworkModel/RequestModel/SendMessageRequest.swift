//
//  SendMessageRequest.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.03.2022..
//

import Foundation

struct SendMessageRequest: Codable {
    var roomId: Int
    var type: String
    var message: MessageTest
}
