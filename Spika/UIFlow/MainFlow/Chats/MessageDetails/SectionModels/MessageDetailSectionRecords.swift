//
//  MessageDetailSectionRecords.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.05.2023..
//

import Foundation

class MessageDetailSectionRecords: MessageDetailsSection {
    let records: [Record]
    
    init(type: MessageDetailsSectionType,
         message: Message,
         records : [MessageRecord],
         user: User,
         sentContacts: [User]) {
        self.records = MessageDetailSectionRecords.sortRecords(records: records, contacts: sentContacts)
        super.init(type: type, message: message, user: user, sentContacts: sentContacts)
    }
    
    private class func sortRecords(records : [MessageRecord], contacts: [User]) -> [Record] {
        var array = [Record]()
        
        for record in records {
            guard let contact = contacts.first(where: { $0.id == record.userId }) else { continue }
            array.append(Record(record, contact))
        }
        
        return array.sorted(by: { $0.user.getDisplayName().localizedCaseInsensitiveCompare($1.user.getDisplayName()) == .orderedAscending })
    }
    
    override func numberOfRows() -> Int {
        if type == .sentTo { return sentContacts.count }
        return records.count
    }
    
    override func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String, editedTime: String?, telephoneNumber: String?)? {
        var time: String = "-"
        var user: User?
        
        if self.type == .deliveredTo || self.type == .readBy {
            user = records[indexPath.row].user
            time = records[indexPath.row].record.createdAt.convert(to: .allChatsTimeFormat)
        }
        
        return (user?.avatarFileId?.fullFilePathFromId() ?? nil,
                user?.getDisplayName() ?? "unknown",
                time, nil, user?.telephoneNumber)
    }
    
}
