//
//  DatabaseService+Update.swift
//  Spika
//
//  Created by Vedran Vugrin on 26.04.2023..
//

import CoreData
import Combine

// MARK: - Users
extension DatabaseService {
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for user in users {
                    if user.displayName == nil {
                        continue // TODO: check
                    }
                    let _ = UserEntity(user: user, context: context)
                }
                do {
                    try context.save()
                    promise(.success(users))
                } catch {
                    print("Core Data Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for contact in contacts {
                    let _ = ContactEntity(phoneNumber: contact.telephone,
                                          givenName: contact.firstName,
                                          familyName: contact.lastName,
                                          context: context)
                }
                do {
                    try context.save()
                    promise(.success(contacts))
                } catch {
                    print("Core Data Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    // TODO: - check
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                for var user in users {
                    //                    saveUsers(users)
                    let fetchRequest = ContactEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", user.telephoneNumber ?? "") // check =
                    do {
                        let fetchResult = try context.fetch(fetchRequest)
                        if let contactEntity = fetchResult.first {
                            let contact = FetchedContact(firstName: contactEntity.givenName,
                                                         lastName: contactEntity.familyName,
                                                         telephone: contactEntity.phoneNumber)
                            user.contactsName = contact.firstName ?? ""
                            + " "
                            + (contact.lastName ?? "")
                        }
                        _ = self?.saveUsers([user])
                    } catch {
                        print("Core Data Error loading: ", error)
                        promise(.failure(DatabaseError.requestFailed))
                    }
                    
                }
                promise(.success(users))
            }
        }
    }
}
 
// MARK: - Room
extension DatabaseService {
    func saveRooms(_ rooms: [Room]) -> Future<[Room], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for room in rooms {
                    let roomEntity = RoomEntity(room: room, context: context)
                    for roomUser in room.users {
                        _ = RoomUserEntity(roomUser: roomUser, insertInto: context)
                        _ = UserEntity(user: roomUser.user, context: context)
                    }
                    // this is because mute or unmute will update room and reset it to zero
                    // TODO: - maybe add functions for update pin, mute
                    roomEntity.lastMessageTimestamp = self?.getLastMessage(roomId: room.id, context: context)?.createdAt ?? 0
                }
                do {
                    try context.save()
                    promise(.success(rooms))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func updateRoomUsers(_ room: Room) -> Future<Room, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let roomUserFR = RoomUserEntity.fetchRequest()
                roomUserFR.predicate = NSPredicate(format: "roomId == %d", room.id)
                
                do {
                    let roomUsers = try context.fetch(roomUserFR)
                    for roomUser in roomUsers {
                        context.delete(roomUser)
                    }
                    try context.save()
                    
                    room.users.forEach { rU in
                        _ = RoomUserEntity(roomUser: rU, insertInto: context)
                    }
                    try context.save()
                    promise(.success(room))
                } catch {
                    print("Core Data Error deleting RoomUsers: \(error)")
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    private func updateRoomLastMessageTimestamp(roomId: Int64, timestamp: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let roomsFR = RoomEntity.fetchRequest()
            roomsFR.predicate = NSPredicate(format: "id == %d", roomId)
            guard let roomEntities = try? context.fetch(roomsFR),
                  roomEntities.count == 1,
                  let entity = roomEntities.first
            else {
                // TODO: - add warning
                return
            }
            if entity.lastMessageTimestamp < timestamp {
                entity.lastMessageTimestamp = timestamp
            }
            do {
                try context.save()
            } catch let error {
                NSLog("Core Data Error: updating Room last message timestamp: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Message
extension DatabaseService {
    func saveMessages(_ messages: [Message]) -> Future<Bool, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                var uniqueRoomIds = Set<Int64>()
                for message in messages {
                    _ = MessageEntity(message: message, context: context)
                    
                    if let file = message.body?.file {
                        _ = FileEntity(file: file, context: context)
                    }
                    
                    if let thumb = message.body?.thumb {
                        _ = FileEntity(file: thumb, context: context)
                    }
                    
                    if let records = message.records {
                        records.forEach { record in
                            _ = MessageRecordEntity(record: record, context: context)
                        }
                    }
                    uniqueRoomIds.insert(message.roomId)
                }
                
                // if save is from sync, refresh every room lastMessageTimestamp
                for roomId in uniqueRoomIds {
                    if let lastMessage = messages.filter({ $0.roomId == roomId }).max(by: {$0.createdAt < $1.createdAt}) {
                        self?.updateRoomLastMessageTimestamp(roomId: lastMessage.roomId, timestamp: lastMessage.createdAt)
                    }
                }
                
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func updateMessageSeenDeliveredCount(messageId: Int64, seenCount: Int64, deliveredCount: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let messageFR = MessageEntity.fetchRequest()
            messageFR.predicate = NSPredicate(format: "id == %d", messageId)
            guard let entity = try? context.fetch(messageFR).first else { return }
            
            if seenCount > entity.seenCount {
                entity.seenCount = seenCount
            }
            
            if deliveredCount > entity.deliveredCount {
                entity.deliveredCount = deliveredCount
            }
            do {
                try context.save()
            } catch let error {
                NSLog("Core Data Error: saving seen delivered count: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateMessagesDummyValue(ids: [Int64]) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let messagesFR = MessageEntity.fetchRequest()
            messagesFR.predicate = NSPredicate(format: "id IN %@", ids)
            
            guard let messageEntities = try? context.fetch(messagesFR) else { return }
            
            messageEntities.forEach { $0.dummyValue = $0.dummyValue + 1 }
            do {
                try context.save()
            } catch let error {
                NSLog("Core Data Error: updating message dummy value: \(error.localizedDescription)")
            }
        }
    }
    
    func resetUnreadCount(_ roomId: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let roomsFR = RoomEntity.fetchRequest()
            roomsFR.predicate = NSPredicate(format: "id = %d", roomId)
            guard let entities = try? context.fetch(roomsFR) else { return }
            entities.forEach { $0.unreadCount = 0 }
            do {
                try context.save()
            } catch let error {
                NSLog("Core Data Error: Resetting Unread Count: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUnreadCounts(_ counts: [UnreadCount]) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            let roomsFR = RoomEntity.fetchRequest()
            
            guard let entities = try? context.fetch(roomsFR) else { return }
            entities.forEach { $0.unreadCount = Int64(0) }
            for count in counts {
                entities.first { $0.id == count.roomId }?.unreadCount = count.unreadCount
            }
            
            do {
                try context.save()
            } catch let error {
                NSLog("Core Data Error: saving Unread Count: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - Message Record & Helper
extension DatabaseService {
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<Bool, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for messageRecord in messageRecords {
                    _ = MessageRecordEntity(record: messageRecord, context: context)
                }
                
                self?.updateMessagesDummyValue(ids: messageRecords.map({ $0.messageId }))
              
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
}
