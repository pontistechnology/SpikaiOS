//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Combine
import CoreData

class AllChatsViewModel: BaseViewModel {
    
    private var roomsFRC: NSFetchedResultsController<RoomEntity>?
    private var messagesFRC: NSFetchedResultsController<MessageEntity>? // only for search
    
    let search = CurrentValueSubject<String?, Error>(nil)
    private let fetchedRoomEntities = CurrentValueSubject<[RoomEntity]?,Never>(nil)
    let rooms = CurrentValueSubject<[Room],Never>([])
    let allRooms = CurrentValueSubject<[Room],Never>([])
    
}

// MARK: - Navigation

extension AllChatsViewModel {
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(for indexPath: IndexPath, scrollToMessage: Bool) {
        if scrollToMessage, let messageEntity = messagesFRC?.object(at: indexPath),
           let messageId = Message(messageEntity: messageEntity, fileData: nil, thumbData: nil, records: nil).id
        {
            guard let roomId = messagesFRC?.object(at: indexPath).roomId,
                  let room = allRooms.value.first(where: { $0.id == roomId })
            else { return }
            getAppCoordinator()?.presentCurrentChatScreen(room: room, scrollToMessageId: messageId)
        } else {
            guard let room = getRoom(for: indexPath) else { return }
            getAppCoordinator()?.presentCurrentChatScreen(room: room)
        }
    }
    
    func onCreateNewRoom() {
        getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: [])
    }
}

// MARK: - Tableview data source

extension AllChatsViewModel {
    // MARK: - Sections
    func getNumberOfSectionForMessages() -> Int {
        return messagesFRC?.sections?.count ?? 0
    }
    
    func titleForSectionForMessages(section: Int) -> String {
        guard let roomId = (messagesFRC?.sections?[section].objects?.first as? MessageEntity)?.roomId,
              let room = allRooms.value.first(where: { $0.id == roomId }),
              let title = .groupRoom == room.type
                ? room.name
                : room.getFriendUserInPrivateRoom(myUserId: getMyUserId())?.getDisplayName()
        else { return "(unknown)" }
        return title
    }
    
    // MARK: - Rows
    
    func getNumberOfRowsForMessages(section: Int) -> Int {
        return messagesFRC?.sections?[section].numberOfObjects ?? 0
    }
    
    func getNumberOfRowsForRooms() -> Int {
        return rooms.value.count
    }
    
    // MARK: - Data
    func dataForCellForRooms(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String,
                                                     description: String, time: String,
                                                     badgeNumber: Int64, muted: Bool, pinned: Bool)? {
        let room = rooms.value[indexPath.row]
        let lastMessage = getLastMessage(for: indexPath)
        let badgeNumber = lastMessage != nil ? room.unreadCount : 0
        
        if room.type == .privateRoom,
           let friendUser = room.getFriendUserInPrivateRoom(myUserId: getMyUserId()) {
            
            return (avatarUrl: friendUser.avatarFileId?.fullFilePathFromId(),
                                name: friendUser.getDisplayName(),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber,
                                muted: room.muted,
                                pinned: room.pinned)
            
        } else {
            
            return (avatarUrl: room.avatarFileId?.fullFilePathFromId(),
                                name: room.name ?? .getStringFor(.noName),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber,
                                muted: room.muted,
                                pinned: room.pinned)
        }
    }
    
    func dataForCellForMessages(at indexPath: IndexPath) -> (String, String, String) {
        guard let messageEntity = messagesFRC?.object(at: indexPath) else { return ("-", "-", "-")}
        let room = allRooms.value.first { $0.id == messageEntity.roomId }
        let userName = messageEntity.fromUserId == getMyUserId() ? "Me" : room?.getDisplayNameFor(userId: messageEntity.fromUserId)
        
        return (userName ?? "-",
                messageEntity.createdAt.convert(to: .ddMMyyyyHHmm),
                messageEntity.bodyText ?? "-")
    }
    
    func description(message: Message?, room: Room) -> String {
        // TODO: - add strings to loc. strings?, this func is needed somewhere else too, move it
        guard let message = message else { return "(No messages)"}
        let desc: String
        if room.type == .privateRoom {
            desc = (message.fromUserId == getMyUserId() ? "Me: " : "")
            + (message.pushNotificationText)
        } else {
            desc = (message.fromUserId == getMyUserId() ? "Me" : ((room.users.first(where: { $0.userId == message.fromUserId })?.user.getDisplayName() ?? "_")))
                    + ": " + (message.pushNotificationText)
        }
        return desc
    }
}

// MARK: - NSFetchedResultsController

extension AllChatsViewModel {
    func setupBinding() {
        fetchedRoomEntities
            .flatMap(maxPublishers: .unlimited) { [weak self] entities in
                guard let self,
                      let context = self.roomsFRC?.managedObjectContext,
                      let entities, entities.count > 0 else {
                    return Future<[Room], Error> { promise in
                        promise(.success([]))
                    }
                }
                
                return self.repository.generateRoomModelsWithUsers(context: context, roomEntities: entities)
                
            }
            .combineLatest(search, { rooms, search in
                self.allRooms.send(rooms)
                guard let search, !search.isEmpty else {
                    return rooms
                }
                let filteredRooms = rooms.filter { room in
                    return room.compareWith(string: search)
                }
                return filteredRooms.sorted { $0.type > $1.type }
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] dt in
                self?.rooms.send(dt)
            })
            .store(in: &subscriptions)
    }
    
    func setRoomsFetch() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = searchPredicate()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        roomsFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        roomsFRC?.delegate = self
        do {
            try roomsFRC?.performFetch()
            fetchedRoomEntities.send(roomsFRC?.fetchedObjects)
        } catch {
            fatalError("Failed to fetch entities: \(error)")
            // TODO: handle error and change main context to func
        }
    }
    
    private func searchPredicate() -> NSPredicate {
        let predicate1 =  NSPredicate(format: "\(#keyPath(RoomEntity.type)) == '\(RoomType.groupRoom.rawValue)' OR \(#keyPath(RoomEntity.lastMessageTimestamp)) > 0 OR \(#keyPath(RoomEntity.unreadCount)) > 0")
        let predicate2 = NSPredicate(format: "\(#keyPath(RoomEntity.roomDeleted)) == false")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
    }
}

// MARK: - NSFRC for messages

extension AllChatsViewModel {
    func setMessagesFetch(searchTerm: String) {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(MessageEntity.bodyText)) CONTAINS[cd] %@ AND \(#keyPath(MessageEntity.isRemoved)) == false ", searchTerm)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MessageEntity.roomId), ascending: false),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: false)
            ]
        self.messagesFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: repository.getMainContext(),
                                               sectionNameKeyPath: #keyPath(MessageEntity.roomId), cacheName: nil)
        messagesFRC?.delegate = self
        try? messagesFRC?.performFetch()
    }
}

// MARK: - Networking

extension AllChatsViewModel {
    func refreshUnreadCounts() {
        repository.refreshUnreadCounts()
    }
}

// MARK: - Database

private extension AllChatsViewModel {
    func getRoom(for indexPath: IndexPath) -> Room? {
        return rooms.value[indexPath.row]
    }
    
    func getLastMessage(for indexPath: IndexPath) -> Message? {
        let room = rooms.value[indexPath.row]
        guard let context = roomsFRC?.managedObjectContext else { return nil }
        return repository.getLastMessage(roomId: room.id, context: context)
    }
}

extension AllChatsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == roomsFRC {
            fetchedRoomEntities.send(roomsFRC?.fetchedObjects)
        } else {
            // MARK: - new message will not appear in search if it arrive while something is searched
        }
    }
}
