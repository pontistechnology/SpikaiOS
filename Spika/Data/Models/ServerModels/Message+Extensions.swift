//
//  Message+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.10.2022..
//

import Foundation

extension Message {
    func getReuseIdentifier(myUserId: Int64, roomType: RoomType) -> String? {
        switch type {
        case .text:
            if myUserId == fromUserId{
                return TextMessageTableViewCell.myTextReuseIdentifier
            } else if roomType == .privateRoom {
                return TextMessageTableViewCell.friendTextReuseIdentifier
            } else {
                return TextMessageTableViewCell.groupTextReuseIdentifier
            }
        case .image:
            if myUserId == fromUserId{
                return ImageMessageTableViewCell.myImageReuseIdentifier
            } else if roomType == .privateRoom {
                return ImageMessageTableViewCell.friendImageReuseIdentifier
            } else {
                return ImageMessageTableViewCell.groupImageReuseIdentifier
            }
        case .file:
            if myUserId == fromUserId{
                return FileMessageTableViewCell.myFileReuseIdentifier
            } else if roomType == .privateRoom {
                return FileMessageTableViewCell.friendFileReuseIdentifier
            } else {
                return FileMessageTableViewCell.groupFileReuseIdentifier
            }
        case .unknown, .video, .audio, .none:
            return nil
        }
    }
}
