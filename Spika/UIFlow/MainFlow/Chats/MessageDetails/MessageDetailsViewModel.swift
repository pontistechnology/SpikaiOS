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
    
    var sections = [MessageDetailsSection]()
    
    var frc: NSFetchedResultsController<MessageRecordEntity>?

    init(repository: Repository, coordinator: Coordinator, users: [User], message: Message) {
        self.allUsers = users.sorted(by: { $0.getDisplayName().localizedCaseInsensitiveCompare($1.getDisplayName()) == .orderedAscending })
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
        return sections[section].numberOfRows()
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String, editedTime: String?, telephoneNumber: String?)? {
        return sections[indexPath.section].getDataForCell(at: indexPath)
    }
    
    // TODO: - check sorting
    func refreshData() {
        guard let allRecords = frc?.fetchedObjects?.map({ MessageRecord(messageRecordEntity: $0) }) else { return }
        let user = allUsers.first(where: { $0.id == message.fromUserId })

        let seenRecords = allRecords.filter({ $0.type == .seen })
        let deliveredRecords = allRecords.filter({ record in
            record.type == .delivered && !seenRecords.contains(where: { r in r.userId == record.userId })
        })
        let sentUsers = allUsers.filter({ user in
            !(seenRecords.contains { r in r.userId == user.id } ||
             deliveredRecords.contains { r in r.userId == user.id })
        })
        
        var sections = [MessageDetailsSection]()
        
        sections.append(MessageDetailsSection(type: .senderActions, message:message, records: [], user: user, sentContacts: allUsers))
        if !seenRecords.isEmpty {
            sections.append(MessageDetailsSection(type: .readBy, message:message, records: seenRecords, user: user, sentContacts: allUsers))
        }
        if !deliveredRecords.isEmpty {
            sections.append(MessageDetailsSection(type: .deliveredTo, message:message, records: deliveredRecords, user: user, sentContacts: allUsers))
        }
        if !sentUsers.isEmpty {
            sections.append(MessageDetailsSection(type: .sentTo, message:message, records: [], user: user, sentContacts: sentUsers))
        }
        
        self.sections = sections
    }
}
