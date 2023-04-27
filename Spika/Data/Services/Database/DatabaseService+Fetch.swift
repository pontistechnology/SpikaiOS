//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//
import CoreData
import Combine

// MARK: - Users
extension DatabaseService {
    
    func getLocalUsers() -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.fetchAsyncEntity(entity: UserEntity.self, completion: { userEntities, error in
                if let error {
                    NSLog("Core Data Error: local user: \(error.localizedDescription)")
                    promise(.failure(DatabaseError.requestFailed))
                } else {
                    let users = userEntities.map{ User(entity: $0) }
                    promise(.success(users.compactMap{ $0 }))
                }
            })
        }
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return Future { [weak self] promise in
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
            
            self?.fetchAsyncData(fetchRequest: fetchRequest, completion: { dbUsers, error in
                if let error {
                    NSLog("Core Data Error: fetching local user: \(error.localizedDescription)")
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
            })
        }
    }
    
    func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]? {
        var roomUsers: [RoomUser]?
        
        let roomUsersFR = RoomUserEntity.fetchRequest()
        roomUsersFR.predicate = NSPredicate(format: "roomId == %d", roomId)
        
        let roomUserEntities = self.fetchDataAndWait(fetchRequest: roomUsersFR) ?? []
        let users = getUsers(id: roomUserEntities.map({ $0.userId }), context: context)
        
        roomUsers = roomUserEntities.compactMap { roomUserEntity in
            guard let user = users?.first(where: { $0.id == roomUserEntity.userId})
            else {
                return nil
            }
            return RoomUser(roomUserEntity: roomUserEntity, user: user)
        }
        
        return roomUsers
    }
    
    private func getUsers(id: [Int64], context: NSManagedObjectContext) -> [User]? {
        let usersFR = UserEntity.fetchRequest()
        usersFR.predicate = NSPredicate(format: "id IN %@", id) // check
        
        let userEntities = self.fetchDataAndWait(fetchRequest: usersFR)
        return userEntities?.map {
            User(entity: $0)
        }
    }
}


// MARK: - Room
extension DatabaseService {
    func getPrivateRoom(forUserId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            let roomUsersFR = RoomUserEntity.fetchRequest()
            roomUsersFR.predicate = NSPredicate(format: "userId == %d", id)
            
            self?.fetchAsyncData(fetchRequest: roomUsersFR, completion: { roomUsers, error in
                guard let self else { return }
                
                if let error {
                    NSLog("Core Data Error: fetching private room: \(error.localizedDescription)")
                    promise(.failure(DatabaseError.noSuchRecord))
                } else {
                    let possibleRoomsIds = roomUsers.map { $0.roomId }
                    let roomFR = RoomEntity.fetchRequest()
                    roomFR.predicate = NSPredicate(format: "type == 'private' AND id IN %@",
                                                   possibleRoomsIds)
                    
                    guard let rooms = self.fetchDataAndWait(fetchRequest: roomFR),
                          rooms.count == 1,
                          let roomEntity = rooms.first,
                          let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: self.coreDataStack.mainMOC) // get all RoomUsers for room, should be always be 2, roomUserEntity and my user
                    else {
                        promise(.failure(DatabaseError.moreThanOne)) // check zero
                        return
                    }
                    
                    let room = Room(roomEntity: roomEntity, users: roomUsers)
                    promise(.success(room))
                }
            })
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
    
    func missingRoomIds(ids: Set<Int64>) -> Future<Set<Int64>, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let roomsFR = RoomEntity.fetchRequest()
                roomsFR.predicate = NSPredicate(format: "id IN %@", ids)
                
                guard let roomsEntities = try? context.fetch(roomsFR) else {
                    promise(.failure(DatabaseError.requestFailed))
                    return
                }
                let fetchedIds = Set(roomsEntities.map { $0.id })
                let dif = ids.subtracting(fetchedIds)
                promise(.success(dif))
            }
        }
    }
}

// MARK: - Message
extension DatabaseService {
     // TODO: - refactorIt
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
                                                   messageText: message.pushNotificationText,
                                                   roomId: room.id,
                                                   isRoomMuted: room.muted)
                } else {
                    info = MessageNotificationInfo(title: room.name ?? "no name",
                                                   photoUrl: room.avatarFileId.fullFilePathFromId(),
                                                   messageText: "\(user.getDisplayName()): " +  message.pushNotificationText,
                                                   roomId: room.id,
                                                   isRoomMuted: room.muted)
                }
                promise(.success(info))
            }
        }
    }
    
    func getLastMessage(roomId: Int64, context: NSManagedObjectContext) -> Message? {
        var message: Message?
        let fr = MessageEntity.fetchRequest()
        fr.predicate = NSPredicate(format: "roomId == %d", roomId)
        fr.fetchLimit = 1
        fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        guard let entity = self.fetchDataAndWait(fetchRequest: fr)?.first else { return nil }
        
        message = Message(messageEntity: entity,
                          fileData: getFileData(id: entity.bodyFileId, context: context),
                          thumbData: getFileData(id: entity.bodyThumbId, context: context),
                       records: [])
        
        return message
    }
}

// MARK: - Message Record & Helper
extension DatabaseService {
    func getReactionRecords(messageId: String?, context: NSManagedObjectContext) -> [MessageRecord]? {
        var records: [MessageRecord]?
        context.performAndWait {
            guard let id = Int64(messageId ?? "failIsOk") else { return }
            let recordsFR = MessageRecordEntity.fetchRequest()
            recordsFR.predicate = NSPredicate(format: "messageId == %d AND type == %@", id, MessageRecordType.reaction.rawValue)
            guard let entities = try? context.fetch(recordsFR),
                  !entities.isEmpty
            else { return }
            records = entities.map { MessageRecord(messageRecordEntity: $0) }
        }
        return records
    }
    

    
    func getFileData(id: String?, context: NSManagedObjectContext) -> FileData? {
        var fileData: FileData?
        context.performAndWait {
            guard let id = id else { return }
            let fr = FileEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %@", id)
            guard let entity = try? context.fetch(fr).first else { return }
            fileData = FileData(entity: entity)
        }
        return fileData
    }
}
