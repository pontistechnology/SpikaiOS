//
//  Message+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.10.2022..
//

import Foundation

extension Message {
    func getReuseIdentifier(myUserId: Int64, roomType: RoomType) -> String? {
        var identifier = ""
        
        if myUserId == fromUserId {
            identifier = MessageSender.me.reuseIdentifierPrefix
        } else if roomType == .privateRoom {
            identifier = MessageSender.friend.reuseIdentifierPrefix
        } else {
            identifier = MessageSender.group.reuseIdentifierPrefix
        }
        
        guard let type = type?.rawValue.capitalized else { return nil }
        return identifier + type + "MessageTableViewCell"
    }
}
