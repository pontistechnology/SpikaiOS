//
//  BlockedUsersResponse.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import Foundation

struct BlockedUsersResponseModel: Decodable {
    let data: BlockedUsers
}

struct BlockedUsers : Decodable {
    let blockedUsers: [User]
}
