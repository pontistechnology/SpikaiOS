//
//  ShareMessageResponseModel.swift
//  Share Extension
//
//  Created by Nikola Barbarić on 23.08.2024..
//

import Foundation

struct ShareMessageResponseModel: Decodable {
    var messages: [Message]
    var newRooms: [Room]
}
