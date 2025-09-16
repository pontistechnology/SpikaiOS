//
//  ForwardMessagesResponse.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.12.2023..
//

import Foundation

struct ForwardMessagesResponseModel: Decodable {
    let status: String?
    let data: ForwardMessagesData?
    let error: String?
    let message: String?
}

struct ForwardMessagesData: Decodable {
    let messages: [Message]
    let newRooms: [Room]
}
