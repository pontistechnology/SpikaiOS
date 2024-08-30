//
//  Constants+Endpoints.swift
//  Spika
//
//  Created by Vedran Vugrin on 13.12.2022..
//

import Foundation

public extension Constants {
    class Endpoints {
        static let getPosts = "posts"
        static let messengerSettings = "api/messenger/settings"
        static let getUserDetails = "api/messenger/me"
        static let authenticateUser = "api/messenger/auth"
        static let verifyCode = "api/messenger/auth/verify"
        static let uploadFiles = "api/upload/files"
        static let verifyFile = "api/upload/files/verify"
        static let userInfo = "api/messenger/me"
        static let contacts = "api/messenger/contacts"
        static let createRoom = "api/messenger/rooms"
        static let checkRoomForUserId = "api/messenger/rooms/users"
        static let checkRoomForRoomId = "api/messenger/rooms"
        static let messages = "api/messenger/messages"
        static let forwardMessages = "api/messenger/messages/forward"
        static let getAllRooms = "api/messenger/rooms"
        static let updatePush = "api/messenger/device"
        static let deliveredStatus = "api/messenger/messages/delivered"
        static let seenStatus = "api/messenger/messages/roomId/seen" // TODO: check roomId
        static let syncRooms = "api/messenger/rooms/sync"
        static let syncAllMessages = "api/messenger/messages/sync"
        static let syncMessageRecords = "api/messenger/message-records/sync"
        static let syncUsers = "api/messenger/users/sync"
        static let messageRecords = "api/messenger/message-records"
        static let blocks = "api/messenger/blocks"
        static let getUnreadCount = "api/messenger/rooms/unread-count"
        static let allRoomNotes = "api/messenger/notes/roomId"
        static let oneNote = "api/messenger/notes"
        static let share = "api/messenger/messages/share"
    }
}
