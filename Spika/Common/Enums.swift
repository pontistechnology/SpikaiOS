//
//  Enums.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.10.2022..
//

import Foundation


enum SyncType {
    case users
    case rooms
    case messages
    case messageRecords
}

enum SSEEventType: String, Codable {
    case newMessage = "NEW_MESSAGE"
    case newMessageRecord = "NEW_MESSAGE_RECORD"
    case deletedMessageRecord = "DELETED_MESSAGE_RECORD"
    case newRoom = "NEW_ROOM"
    case updateRoom = "UPDATE_ROOM"
    case deleteRoom = "DELETE_ROOM"
    case userUpdate = "USER_UPDATE"
}

enum RoomType: String, Codable {
    case privateRoom = "private"
    case groupRoom = "group"
}

// TODO: move this
struct MessageNotificationInfo {
    let title: String
    let photoUrl: String
    let messageText: String
}

enum CustomFontName: String {
    case MontserratRegular = "Montserrat-Regular"
    case MontserratBold = "Montserrat-Bold"
    case MontserratBlack = "Montserrat-Black"
    case MontserratExtraBold = "Montserrat-ExtraBold"
    case MontserratExtraLight = "Montserrat-ExtraLight"
    case MontserratLight = "Montserrat-Light"
    case MontserratMedium = "Montserrat-Medium"
    case MontserratSemiBold = "Montserrat-SemiBold"
    case MontserratThin = "Montserrat-Thin"
}
