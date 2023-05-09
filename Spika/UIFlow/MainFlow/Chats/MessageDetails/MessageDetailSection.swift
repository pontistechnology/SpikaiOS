//
//  MessageDetailSection.swift
//  Spika
//
//  Created by Vedran Vugrin on 09.05.2023..
//

import Foundation

enum MessageDetailsSectionType {
    case senderActions, readBy, deliveredTo, sentTo
    func titleString() -> String {
        switch self {
        case .senderActions:
            return .getStringFor(.senderActions)
        case .readBy:
            return .getStringFor(.readBy)
        case .deliveredTo:
            return .getStringFor(.deliveredTo)
        case .sentTo :
            return .getStringFor(.sentTo)
        }
    }
}

final class MessageDetailsSection {
    
    typealias Record = (record: MessageRecord, user: User)
    
    let type: MessageDetailsSectionType
    let message: Message
    var user: User?
    var records: [Record]?
    var sentContacts: [User]?
    
    
    init(type: MessageDetailsSectionType,
         message: Message,
         records : [MessageRecord],
         user: User?,
         sentContacts: [User]? = nil) {
        self.type = type
        self.message = message
        self.user = user
        self.sentContacts = sentContacts
        
        if !records.isEmpty {
            self.records = self.sortRecords(records: records, contacts: sentContacts!)
        }
    }
    
    func sortRecords(records : [MessageRecord], contacts: [User]) -> [Record]? {
        var array = [Record]()
        
        for record in records {
            guard let contact = contacts.first(where: { $0.id == record.userId }) else { continue }
            array.append(Record(record, contact))
        }
        
        return array.sorted(by: { $0.user.getDisplayName().localizedCaseInsensitiveCompare($1.user.getDisplayName()) == .orderedAscending })
    }
    
    func numberOfRows() -> Int {
        if type == .senderActions { return 1 }
        if type == .sentTo { return sentContacts!.count }
        return records!.count
    }
    
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String, editedTime: String?, telephoneNumber: String?)? {
        let time: String
        var editedTime: String?
        
        switch self.type {
        case .senderActions:
            time = message.createdAt.convert(to: .allChatsTimeFormat)
            editedTime = message.modifiedAt.convert(to: .allChatsTimeFormat)
        case .readBy:
            user = records?[indexPath.row].user
            time = records![indexPath.row].record.createdAt.convert(to: .allChatsTimeFormat)
        case .deliveredTo:
            user = records?[indexPath.row].user
            time = records![indexPath.row].record.createdAt.convert(to: .allChatsTimeFormat)
        case .sentTo:
            user = sentContacts![indexPath.row]
            time = "-"
        }
        return (user?.avatarFileId?.fullFilePathFromId() ?? nil,
                user?.getDisplayName() ?? "unknown",
                time, editedTime, user?.telephoneNumber)
    }
    
}
