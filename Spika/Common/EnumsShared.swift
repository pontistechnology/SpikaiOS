//
//  Enums.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.10.2022..
//

import UIKit

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




