//
//  Constants.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

struct Constants {
    struct Strings {
        static let appName = "Spika"
        static let cancel = "Cancel"
        static let appGroupName = "group.studio.clover.Spika.groupSpika"
    }
    
    struct Networking {
        static let baseUrl = "https://dev3.spika.chat/"
    }
    
    struct Endpoints {
        static let getPosts = "posts"
        static let getUserDetails = "/api/messenger/me"
        static let authenticateUser = "api/messenger/auth"
        static let verifyCode = "api/messenger/auth/verify"
        static let uploadFiles = "api/upload/files"
        static let verifyFile = "api/upload/files/verify"
        static let userInfo = "api/messenger/me"
        static let contacts = "api/messenger/contacts"
        static let createRoom = "api/messenger/rooms"
        static let checkRoomForUserId = "api/messenger/rooms/users"
        static let checkRoomForRoomId = "api/messenger/rooms"
        static let sendMessage = "api/messenger/messages"
        static let getAllRooms = "api/messenger/rooms"
        static let updatePush = "api/messenger/device"
        static let deliveredStatus = "api/messenger/messages/delivered"
        static let syncRooms = "api/messenger/rooms/sync"
        static let syncMessages = "api/messenger/messages/sync"
        static let syncMessageRecords = "api/messenger/message-records/sync"
        static let syncUsers = "api/messenger/users/sync"
    }
    
    struct Database {
        static let databaseName = "CoreDatabase"
        static let userEntity = "UserEntity"
        static let messageEntity = "MessageEntity"
        static let messageRecordEntity = "MessageRecordEntity"
        static let roomEntity = "RoomEntity"
        static let roomUserEntity = "RoomUserEntity"
        static let contactEntity = "ContactEntity"
    }
    
    struct UserDefaults {
        static let userId = "userId"
        static let userPhoneNumber = "userPhoneNumber"
        static let deviceId = "deviceId"
        static let accessToken = "accessToken"
        static let displayName = "displayName"
        static let pushToken = "pushToken"
        static let roomsSyncTimestamp = "roomsSyncTimestamp"
        static let usersSyncTimestamp = "usersSyncTimestamp"
        static let messagesSyncTimestamp = "messagesSyncTimestamp"
        static let messageRecordsSyncTimestamp = "messageRecordsSyncTimestamp"
    }
    
    struct CABasicAnimations {
        static let circularProgressStroke = "circularProgressStroke"
    }
    
}
