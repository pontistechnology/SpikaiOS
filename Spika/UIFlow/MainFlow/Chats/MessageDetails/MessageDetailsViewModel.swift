//
//  MessageDetailsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 30.03.2023..
//

import Foundation
import CoreData

class MessageDetailsViewModel: BaseViewModel {
    private let allUsers: [User]
    private let message: Message
    private var allRecords: [MessageRecord] = []
    private var seenRecords: [MessageRecord] = []
    private var deliveredRecords: [MessageRecord] = []
    private var sentUsers: [User] = []
    let sectionTitles = ["Sender actions", .getStringFor(.readBy), .getStringFor(.deliveredTo), .getStringFor(.sentTo)]
    
    var frc: NSFetchedResultsController<MessageRecordEntity>?

    init(repository: Repository, coordinator: Coordinator, users: [User], message: Message) {
        self.allUsers = users
        self.message = message
        super.init(repository: repository, coordinator: coordinator)
    }
}

extension MessageDetailsViewModel {
    func setFetch() {
        guard let messageId = message.id else { return }
        let fetchRequest = MessageRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(type != 'reaction' AND messageId == %d)", messageId)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: #keyPath(MessageRecordEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                              sectionNameKeyPath: "type",
                                              cacheName: nil)
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
        refreshData()
    }
}

extension MessageDetailsViewModel {
    func numberOfRows(in section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return seenRecords.count
        case 2:
            return deliveredRecords.count
        case 3:
            return sentUsers.count
        default:
            return 0
        }
    }
    
    func numberOfSections() -> Int {
        return sectionTitles.count
    }
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String, editedTime: String?, telephoneNumber: String?)? {
        let user: User?
        let time: String
        var editedTime: String?
        switch indexPath.section {
        case 0:
            user = allUsers.first(where: { $0.id == message.fromUserId })
            time = message.createdAt.convert(to: .allChatsTimeFormat)
            editedTime = message.modifiedAt.convert(to: .allChatsTimeFormat)
        case 1:
            user = allUsers.first(where: { $0.id == seenRecords[indexPath.row].userId })
            time = seenRecords[indexPath.row].createdAt.convert(to: .allChatsTimeFormat)
        case 2:
            user = allUsers.first(where: { $0.id == deliveredRecords[indexPath.row].userId })
            time = deliveredRecords[indexPath.row].createdAt.convert(to: .allChatsTimeFormat)
        case 3:
            user = sentUsers[indexPath.row]
            time = "-"
        default:
            return nil
        }
        return (user?.avatarFileId?.fullFilePathFromId() ?? nil,
                user?.getDisplayName() ?? "unknown",
                time, editedTime, user?.telephoneNumber)
    }
    
    // TODO: - check sorting
    func refreshData() {
        guard let allRecords = frc?.fetchedObjects?.map({ MessageRecord(messageRecordEntity: $0) }) else { return }
        self.allRecords = allRecords
        seenRecords = allRecords.filter({ $0.type == .seen })
        deliveredRecords = allRecords.filter({ record in
            record.type == .delivered && !seenRecords.contains(where: { r in r.userId == record.userId })
        })
        sentUsers = allUsers.filter({ user in
            !(seenRecords.contains { r in r.userId == user.id } ||
             deliveredRecords.contains { r in r.userId == user.id })
        })
    }
}
