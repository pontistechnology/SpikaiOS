//
//  Constants+Database.swift
//  Spika
//
//  Created by Vedran Vugrin on 13.12.2022..
//

import Foundation

public extension Constants {
    class Database {
        static let databaseName = "CoreDatabase"
        static let userEntity = "UserEntity"
        static let messageEntity = "MessageEntity"
        static let fileEntity = "FileEntity"
        static let messageRecordEntity = "MessageRecordEntity"
        static let roomEntity = "RoomEntity"
        static let roomUserEntity = "RoomUserEntity"
        static let contactEntity = "ContactEntity"
        static let userId = "userId"
        static let userPhoneNumberCountryCode = "userPhoneNumberCountryCode"
        static let userPhoneNumberRest = "userPhoneNumberRest"
        static let deviceId = "deviceId"
        static let accessToken = "accessToken"
        static let selectedAppereanceMode = "selectedAppereanceMode"
        static let displayName = "displayName"
        static let pushToken = "pushToken"
        static let roomsSyncTimestamp = "roomsSyncTimestamp"
        static let usersSyncTimestamp = "usersSyncTimestamp"
        static let messagesSyncTimestamp = "messagesSyncTimestamp"
        static let messageRecordsSyncTimestamp = "messageRecordsSyncTimestamp"
        static let serverSettings = "serverSettings"
    }
}
