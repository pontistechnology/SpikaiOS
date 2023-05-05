//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Combine
import CoreData

class AllChatsViewModel: BaseViewModel {
    
    private var frc: NSFetchedResultsController<RoomEntity>?
    
    private func predicateWithSearch(search: String? = nil) -> NSPredicate {
        let predicate1 =  NSPredicate(format: "\(#keyPath(RoomEntity.type)) == '\(RoomType.groupRoom.rawValue)' OR \(#keyPath(RoomEntity.lastMessageTimestamp)) > 0 OR \(#keyPath(RoomEntity.unreadCount)) > 0")
        let predicate2 = NSPredicate(format: "\(#keyPath(RoomEntity.roomDeleted)) == false")
        
        if let search {
            let searchPredicate = NSPredicate(format: "\(#keyPath(RoomEntity.name)) CONTAINS[c] %@", search)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, predicate1, predicate2])
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        }
    }
    
    let search = CurrentValueSubject<String?, Error>(nil)
    private let fetchedRoomEntities = CurrentValueSubject<[RoomEntity]?,Never>(nil)
    let rooms = CurrentValueSubject<[Room],Never>([])
    
}

// MARK: - Navigation

extension AllChatsViewModel {
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(for indexPath: IndexPath) {
        guard let room = getRoom(for: indexPath) else { return }
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
}

// MARK: - Tableview data source

extension AllChatsViewModel {
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String,
                                                     description: String, time: String,
                                                     badgeNumber: Int64, muted: Bool, pinned: Bool)? {
        let room = self.rooms.value[indexPath.row]
        let lastMessage = getLastMessage(for: indexPath)
        
        if room.type == .privateRoom,
           let friendUser = room.getFriendUserInPrivateRoom(myUserId: getMyUserId()) {
            
            return (avatarUrl: friendUser.avatarFileId?.fullFilePathFromId(),
                                name: friendUser.getDisplayName(),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: room.unreadCount,
                                muted: room.muted,
                                pinned: room.pinned)
            
        } else {
            
            return (avatarUrl: room.avatarFileId?.fullFilePathFromId(),
                                name: room.name ?? .getStringFor(.noName),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: room.unreadCount,
                                muted: room.muted,
                                pinned: room.pinned)
        }
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
        self.fetchedRoomEntities
            .flatMap(maxPublishers: .unlimited) { [weak self] entities in
                guard let self,
                        let context = self.frc?.managedObjectContext,
                      let entities, entities.count > 0 else {
                    return Future<[Room], Error> { promise in
                        promise(.success([]))
                    }
                }
                return self.repository.generateRoomModelsWithUsers(context: context, roomEntities: entities)
            }
            .combineLatest(self.search, { rooms, search in
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
        fetchRequest.predicate = self.predicateWithSearch()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        self.frc?.delegate = self
        do {
            try self.frc?.performFetch()
            self.fetchedRoomEntities.send(self.frc?.fetchedObjects)
        } catch {
            fatalError("Failed to fetch entities: \(error)")
            // TODO: handle error and change main context to func
        }
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
        let room = self.rooms.value[indexPath.row]
        return room
    }
    
    func getLastMessage(for indexPath: IndexPath) -> Message? {
        let room = self.rooms.value[indexPath.row]
        guard let context = self.frc?.managedObjectContext else { return nil }
        return repository.getLastMessage(roomId: room.id, context: context)
    }
}

extension AllChatsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedRoomEntities.send(self.frc?.fetchedObjects)
    }
}
