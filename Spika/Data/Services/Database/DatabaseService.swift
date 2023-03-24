//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//
import CoreData
import Combine

enum DatabaseError: Error {
    case requestFailed, noSuchRecord, unknown, moreThanOne, savingError
    
    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        case .moreThanOne: return "More than one record."
        case .savingError: return "Saving error."
        }
    }
}

class DatabaseService {
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

// MARK: -  User

extension DatabaseService {
    func getLocalUsers() -> Future<[User], Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                let fetchRequest = UserEntity.fetchRequest()
                do {
                    let userEntities = try context.fetch(fetchRequest)
                    let users = userEntities.map{ User(entity: $0) }
                    promise(.success(users.compactMap{ $0 }))
                } catch {
                    print("Error loading: ", error)
                    promise(.failure(DatabaseError.requestFailed))
                }
            }
        }
    }
     // meaningless
    func saveUser(_ user: User) -> Future<User, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let _ = UserEntity(user: user, context: context)
                do {
                    try context.save()
                    promise(.success(user))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
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
                    print("Error saving: ", error)
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
                    print("Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    // TODO: - check
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
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
                        _ = self?.saveUser(user)
                    } catch {
                        print("Error loading: ", error)
                        promise(.failure(DatabaseError.requestFailed))
                    }
                    
                }
                promise(.success(users))
            }
        }
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let fetchRequest = UserEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
                do {
                    let dbUsers = try context.fetch(fetchRequest)
                    if dbUsers.count == 0 {
                        promise(.failure(DatabaseError.noSuchRecord))
                    } else if dbUsers.count > 1 {
                        promise(.failure(DatabaseError.moreThanOne))
                    } else {
                        guard let userEntity = dbUsers.first else {
                            print("GUARD getLocalUser(withId id: Int64) error: ")
                            promise(.failure(DatabaseError.unknown))
                            return
                        }
                        let user = User(entity: userEntity)
                        promise(.success(user))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

// MARK: - Room

extension DatabaseService {
    func getPrivateRoom(forUserId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }

                // find all roomUsers
                let roomUsersFR = RoomUserEntity.fetchRequest()
                roomUsersFR.predicate = NSPredicate(format: "userId == %d", id)
                guard let roomUsers = try? context.fetch(roomUsersFR)
                else {
                    promise(.failure(DatabaseError.noSuchRecord)) // check
                    return
                }
                
                // find all private rooms with this users, should always be only one
                let possibleRoomsIds = roomUsers.map { $0.roomId }
                let roomFR = RoomEntity.fetchRequest()
                roomFR.predicate = NSPredicate(format: "type == 'private' AND id IN %@",
                                               possibleRoomsIds)
                guard let rooms = try? context.fetch(roomFR),
                      rooms.count == 1,
                      let roomEntity = rooms.first,
                      let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: context) // get all RoomUsers for room, should be always be 2, roomUserEntity and my user
                else {
                    promise(.failure(DatabaseError.moreThanOne)) // check zero
                    return
                }
                
                let room = Room(roomEntity: roomEntity, users: roomUsers)
                promise(.success(room))
            }
        }
    }
    
    func getRoom(forRoomId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }
                let roomsFR = RoomEntity.fetchRequest()
                roomsFR.predicate = NSPredicate(format: "id == %d", id)
                guard let roomEntities = try? context.fetch(roomsFR),
                      roomEntities.count == 1,
                      let roomEntity = roomEntities.first,
                      let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: context)
                else {
                    promise(.failure(DatabaseError.moreThanOne)) // check zero
                    return
                }
                let room = Room(roomEntity: roomEntity, users: roomUsers)
                promise(.success(room))
            }
        }
    }
    
    private func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]? {
        // fetch all [RoomUserEntity] from database
        let roomUsersFR = RoomUserEntity.fetchRequest()
        roomUsersFR.predicate = NSPredicate(format: "roomId == %d", roomId)
        
        guard let roomUserEntities = try? context.fetch(roomUsersFR)
        else {
            return nil
        }
        
        // fetch all [User] from database
        let users = getUsers(id: roomUserEntities.map({ $0.userId }), context: context)
        
        // return [RoomUser], should be same count as [RoomUserEntity]
        
        return roomUserEntities.compactMap { roomUserEntity in
            guard let user = users?.first(where: { $0.id == roomUserEntity.userId})
            else {
                return nil
            }
            return RoomUser(roomUserEntity: roomUserEntity, user: user)
        }
    }
    
    private func getUsers(id: [Int64], context: NSManagedObjectContext) -> [User]? {
        let usersFR = UserEntity.fetchRequest()
        usersFR.predicate = NSPredicate(format: "id IN %@", id) // check
        guard let userEntities = try? context.fetch(usersFR)
        else {
            return nil
        }
        return userEntities.map {
            User(entity: $0)
        }
    }
        
    func saveRooms(_ rooms: [Room]) -> Future<[Room], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for room in rooms {
                    let _ = RoomEntity(room: room, context: context)
                    for roomUser in room.users {
                        _ = RoomUserEntity(roomUser: roomUser, insertInto: context)
                        _ = UserEntity(user: roomUser.user, context: context)
                    }
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
        // TODO: - dbr
        // maybe delete all roomUsers with that room id, then save new ones
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
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
                    print("Error deleting RoomUsers: \(error)")
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func roomVisited(roomId: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            let fr = RoomEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %d", roomId)
            guard let rooms = try? context.fetch(fr) else { return }
            
            if rooms.count == 1 {
                rooms.first!.visitedRoom = Date().currentTimeMillis()
            } else {
                print("MORE THAN ONE ROOM.")
            }
            
            try? context.save()
        }
    }
    
    func deleteRoom(roomId: Int64) -> Future<Bool, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let fr = RoomEntity.fetchRequest()
                fr.predicate = NSPredicate(format: "id == %d", roomId)
                guard let roomEntity = try? context.fetch(fr).first else { return }
                
                context.delete(roomEntity)
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure((DatabaseError.savingError)))
                }
            }
        }
    }
}

// MARK: - Message

extension DatabaseService {
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
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
                }
                // TODO: - dbr add last timestamp, group
                if let lastMessage = messages.max(by: { $0.createdAt < $1.createdAt }) {
                    self?.updateRoomLastMessageTimestamp(context: context, roomId: lastMessage.roomId, timestamp: lastMessage.createdAt)
                }
                
                do {
                    try context.save()
                    promise(.success(messages))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func updateRoomLastMessageTimestamp(context: NSManagedObjectContext, roomId: Int64, timestamp: Int64) {
        let roomsFR = RoomEntity.fetchRequest()
        roomsFR.predicate = NSPredicate(format: "id == %d", roomId)
        guard let roomEntities = try? context.fetch(roomsFR),
              roomEntities.count == 1
        else {
            return
        }
        // TODO: - dbr check if timestamp is greater than lastMessageTimestamp
        roomEntities.first?.lastMessageTimestamp = timestamp
        try? context.save()
    }
    
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for messageRecord in messageRecords {
                    _ = MessageRecordEntity(record: messageRecord, context: context)
                }
              
                do {
                    try context.save()
                    promise(.success(messageRecords))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func getLastMessage(roomId: Int64) -> Message? {
        let fr = MessageEntity.fetchRequest()
        fr.predicate = NSPredicate(format: "roomId == %d", roomId)
        fr.fetchLimit = 1
        fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        guard let entity = try? coreDataStack.mainMOC.fetch(fr).first else { return nil}
        
        return Message(messageEntity: entity,
                       fileData: getFileData(id: entity.bodyFileId),
                       thumbData: getFileData(id: entity.bodyThumbId),
                       records: [])
    }
    
    func getFileData(id: String?) -> FileData? {
        guard let id = id else { return nil }
        let fr = FileEntity.fetchRequest()
        fr.predicate = NSPredicate(format: "id == %@", id)
        guard let entity = try? coreDataStack.mainMOC.fetch(fr).first else {
            return nil
        }
        return FileData(entity: entity)
    }
    
    func getNotificationInfoForMessage(message: Message) -> Future<MessageNotificationInfo, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // fetch room from database
                let roomEntiryFR = RoomEntity.fetchRequest()
                roomEntiryFR.predicate = NSPredicate(format: "id == %d", message.roomId)
                
                guard let rooms = try? context.fetch(roomEntiryFR),
                      rooms.count == 1,
                      let room = rooms.first,
                      let user = self.getUsers(id: [message.fromUserId], context: context)?.first
                else {
                    promise(.failure(DatabaseError.unknown))
                    return
                }
                
                let info: MessageNotificationInfo
                
                if room.type == RoomType.privateRoom.rawValue {
                    info = MessageNotificationInfo(title: user.getDisplayName(),
                                                   photoUrl: user.avatarFileId?.fullFilePathFromId(),
                                                   messageText: message.body?.text ?? message.type.pushNotificationText)
                } else {
                    info = MessageNotificationInfo(title: room.name ?? "no name",
                                                   photoUrl: room.avatarFileId.fullFilePathFromId(),
                                                   messageText: "\(user.getDisplayName()): " + (message.body?.text ?? message.type.pushNotificationText))
                }
                promise(.success(info))
                
                
            }
        }

    }
}
