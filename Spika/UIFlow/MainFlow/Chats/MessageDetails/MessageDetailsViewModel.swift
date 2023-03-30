//
//  MessageDetailsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 30.03.2023..
//

import Foundation
import CoreData

class MessageDetailsViewModel: BaseViewModel {
    let users: [User]
    let messageId: Int64
    var frc: NSFetchedResultsController<MessageRecordEntity>?
    
    init(repository: Repository, coordinator: Coordinator, users: [User], messageId: Int64) {
        self.users = users
        self.messageId = messageId
        super.init(repository: repository, coordinator: coordinator)
    }
}

extension MessageDetailsViewModel {
    func setFetch() {
        let fetchRequest = MessageRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messageId == %d AND type != 'reaction'", messageId)
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
    }
}

extension MessageDetailsViewModel {
    func numberOfRows(in section: Int) -> Int {
        guard let sections = frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func numberOfSections() -> Int {
        return frc?.sections?.count ?? 0
    }
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String)? {
        guard let entity = frc?.object(at: indexPath) else { return nil }
        let user = users.first(where: { $0.id == entity.userId})
        return (user?.avatarFileId?.fullFilePathFromId(),
                user?.getDisplayName() ?? "",
                entity.createdAt.convert(to: .allChatsTimeFormat))
    }
}
