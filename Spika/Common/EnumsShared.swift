//
//  Enums.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.10.2022..
//

import UIKit
import Combine

enum RoomType: String, Codable, Comparable {
    case privateRoom = "private"
    case groupRoom = "group"
    
    static func <(lhs: RoomType, rhs: RoomType) -> Bool {
        if lhs == rhs { return false }
        return lhs == .groupRoom
    }
}

enum MessageRecordType: String, Codable {
    case seen = "seen"
    case delivered = "delivered"
    case reaction = "reaction"
    case unknown = "unknown"
    
    public init(from decoder: Decoder) throws {
        self = try MessageRecordType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

// TODO: - move structs
struct SelectedFile {
    let fileType: MessageType
    var name: String?
    let fileUrl: URL
    let thumbUrl: URL?
    let thumbMetadata: MetaData?
    let metaData: MetaData
    let mimeType: String
    let localId: String
}

struct MessageNotificationInfo {
    let title: String
    let photoUrl: URL?
    let messageText: String
    let roomId: Int64
    let isRoomMuted: Bool
}

enum SyncType {
    case users
    case rooms
    case messages
    case messageRecords
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

enum DeleteMessageTarget: String, Codable {
    case all
    case user
}

enum ImagePickerError: Error {
    case badQuality, wrongDimensions

    var description : String {
        switch self {
        case .badQuality:
            return "Please use better quality"
        case .wrongDimensions:
            return "Please select a square"
        }
  }
}

enum WarningOrResult<Success> {
    case warning(String)
    case result(Success)
}

struct Emoji: Codable {
    let hexCodes: [Int]
    let desc: String
    let variations: [[Int]]
    
    var display: String {
        return combineScalars(hexCodes: hexCodes)
    }
    
    var variationsToShow: [String]? {
        guard !variations.isEmpty else { return nil }
        var aa: [String] = []
        variations.forEach { variation in
            aa.append(combineScalars(hexCodes: variation))
        }
        return aa
    }
    
    func combineScalars(hexCodes: [Int]) -> String {
        var myString = ""
        for hexCode in hexCodes {
            guard let scalar = UnicodeScalar(hexCode) else { return "" }
            myString = myString + String(scalar)
        }
        return myString
    }
}

enum AppAction {
    case deleteReaction(Int64)
    case newGroupFlowSelectUsers([User])
    case forwardMessages(messageIds: [Int64], userIds: [Int64], roomIds: [Int64])
    case addToExistingRoom([Int64])
    case updateRoom(room: Room)
}

enum UpdateRoomAction {
    case addGroupUsers(userIds: [Int64])
    case removeGroupUsers(userIds: [Int64])
    case addGroupAdmins(userIds: [Int64])
    case removeGroupAdmins(userIds: [Int64])
    case changeGroupName(newName: String)
    case changeGroupAvatar(fileId: Int64)
    
    var action: String {
        switch self {
        case .addGroupUsers:
            "addGroupUsers"
        case .removeGroupUsers:
            "removeGroupUsers"
        case .addGroupAdmins:
            "addGroupAdmins"
        case .removeGroupAdmins:
            "removeGroupAdmins"
        case .changeGroupName:
            "changeGroupName"
        case .changeGroupAvatar:
            "changeGroupAvatar"
        }
    }
}

enum ChatDetailsMode {
    case contact(User)
    case roomDetails(CurrentValueSubject<Room, Never>)
    
    var description: String {
        return switch self {
        case .contact:
            .getStringFor(.privateContact)
        case .roomDetails:
            .getStringFor(.group)
        }
    }
    
    var isPrivate: Bool {
        return switch self {
        case .contact: true
        case .roomDetails: false
        }
    }
    
    var isGroup: Bool { !isPrivate }
    
    var room: Room? {
        return if case .roomDetails(let currentValueSubject) = self {
            currentValueSubject.value
        } else {
            nil
        }
    }
}
