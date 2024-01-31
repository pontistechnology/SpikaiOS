//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation
import UIKit

struct Message: Codable {
    let createdAt: Int64
    let modifiedAt: Int64
    let fromUserId: Int64
    let roomId: Int64
    let id: Int64?
    let localId: String?
    let totalUserCount: Int64?
    let deliveredCount: Int64?
    let seenCount: Int64?
    let replyId: Int64?
    let deleted: Bool
    let isForwarded: Bool
    let type: MessageType
    let body: MessageBody?
    let records: [MessageRecord]?
}

extension Message {
    init(createdAt: Int64, fromUserId: Int64, roomId: Int64, type: MessageType, body: MessageBody, replyId: Int64?, localId: String) {
        self.body = body
        self.id = nil
        self.localId = localId
        self.fromUserId = fromUserId
        self.totalUserCount = -1
        self.deliveredCount = -2 // needs to be different all 3 values, because state is calculated from this
        self.seenCount = -3
        self.replyId = replyId
        self.roomId = roomId
        self.type = type
        self.deleted = false
        self.isForwarded = false
        self.createdAt = createdAt
        self.modifiedAt = createdAt
        self.records = nil
    }
    
    init(messageEntity: MessageEntity, fileData: FileData?, thumbData: FileData?, records: [MessageRecord]?) {
        self.init(createdAt: messageEntity.createdAt,
                  modifiedAt: messageEntity.modifiedAt,
                  fromUserId: messageEntity.fromUserId,
                  roomId: messageEntity.roomId,
                  id: Int64(messageEntity.id ?? "nil"),
                  localId: messageEntity.localId,
                  totalUserCount: messageEntity.totalUserCount,
                  deliveredCount: messageEntity.deliveredCount,
                  seenCount: messageEntity.seenCount,
                  replyId: Int64(messageEntity.replyId ?? "nil"),
                  deleted: messageEntity.isRemoved, 
                  isForwarded: messageEntity.isForwarded,
                  type: MessageType(rawValue: messageEntity.type ?? "") ?? .unknown, // check
                  body: MessageBody(text: messageEntity.bodyText ?? "",
                                    file: fileData, thumb: thumbData, 
                                    type: MessageBodyType(rawValue: messageEntity.bodyType), subject: messageEntity.bodySubject, subjectId: Int64(messageEntity.bodySubjectId ?? "failIsOk"), objects: messageEntity.bodyObjects, objectIds: messageEntity.bodyObjectIds),
                  records: records)
    }
    
    func getMessageState(myUserId: Int64) -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
//        print("getMessageState: \(id)", "dc: ", deliveredCount, "tc: ", totalUserCount)
        if seenCount == totalUserCount {
            return .seen
        }
        
        if deliveredCount == totalUserCount {
            return .delivered
        }
        
        if id != nil {
            return .sent
        }
        return .waiting
    }
    
    var pushNotificationText: String {
        switch type {
        case .text:
            body?.text ?? " "
        case .image:
            "Photo"
        case .video:
            "Video"
        case .file:
            "File"
        case .audio:
            "Audio"
        case .unknown:
            "Unknown"
        case .system:
            body?.text ?? " "
        }
    }
    
    var reactionRecords: [MessageRecord] {
        records?.filter({ !$0.isDeleted && $0.reaction != "Deleted reaction"}) ?? []
    }
}

struct MessageBody: Codable {
    // used everywhere
    let text: String?
    // used for files
    let file: FileData?
    let thumb: FileData?
    // used for system messages
    let type: MessageBodyType?
    let subject: String?
    let subjectId: Int64?
    let objects: [String]?
    let objectIds: [Int64]?
}

extension MessageBody {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.file = try container.decodeIfPresent(FileData.self, forKey: .file)
        self.thumb = try container.decodeIfPresent(FileData.self, forKey: .thumb)
        self.subject = try container.decodeIfPresent(String.self, forKey: .subject)
        self.subjectId = try container.decodeIfPresent(Int64.self, forKey: .subjectId)
        self.objects = try container.decodeIfPresent([String].self, forKey: .objects)
        self.objectIds = try container.decodeIfPresent([Int64].self, forKey: .objectIds)

        // Decode the raw string for the enum, and use the failable initializer
        if let typeString = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = MessageBodyType(rawValue: typeString)
        } else {
            self.type = nil
        }
    }
}

enum MessageBodyType: String, Codable {
    case createdGroup = "created_group"
    case userLeftGroup = "user_left_group"
    case updatedGroupName = "updated_group_name"
    case updatedGroupAvatar = "updated_group_avatar"
    case addedGroupMembers = "added_group_members"
    case removedGroupMembers = "removed_group_members"
    case addedGroupAdmins = "added_group_admins"
    case removedGroupAdmins = "removed_group_admins"
    case createdNote = "created_note"
    case updatedNote = "updated_note"
    case deletedNote = "deleted_note"
    
    init?(rawValue: String?) {
        if let string = rawValue,
            let val = MessageBodyType(rawValue: string) {
            self = val
        } else {
            return nil
        }
    }
}

enum MessageType: String, Codable {
    // Type is used for MessageCells reuseIdentifier too
    case text
    case image
    case video
    case file
    case audio
    case system
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try MessageType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    var icon: UIImage? {
        switch self {
        case .text:
            nil
        case .image:
            UIImage(resource: .photoIcon)
        case .video:
            UIImage(resource: .videoIcon)
        case .file:
            UIImage(resource: .docIcon)
        case .audio:
            UIImage(resource: .micIcon)
        case .unknown:
            UIImage(resource: .unknownFileThumbnail)
        case .system:
            nil
        }
    }
}

enum MessageState {
    case sent
    case delivered
    case seen
    case fail
    case waiting
}
