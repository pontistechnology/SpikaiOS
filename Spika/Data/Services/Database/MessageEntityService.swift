//
//  MessageEntityService.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import UIKit
import CoreData
import Combine

class MessageEntityService {
    
    let coreDataStack: CoreDataStack!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
        
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for message in messages {
                    let messageEntity = MessageEntity(message: message, context: context)
                }
                // TODO: - dbr add last timestamp
                
                do {
                    try context.save()
                    promise(.success(messages))
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for messageRecord in messageRecords {
                    _ = MessageRecordEntity(record: messageRecord, context: context)
                }
              
                do {
                    try context.save()
                    promise(.success(messageRecords))
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
}

extension MessageEntityService {
    // copy exist
    private func getUsers(id: [Int64], context: NSManagedObjectContext) -> [User]? {
        let usersFR = UserEntity.fetchRequest()
        usersFR.predicate = NSPredicate(format: "id IN %@", id) // check
        guard let userEntities = try? context.fetch(usersFR)
        else {
            return nil
        }
        return userEntities.map { userEntity in
            User(entity: userEntity)
        }
    }
    
    func getNotificationInfoForMessage(message: Message) -> Future<MessageNotificationInfo, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistantContainer.performBackgroundTask { [weak self] context in
                guard let self = self else { return }
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // fetch room from database
                let roomEntiryFR = RoomEntity.fetchRequest()
                roomEntiryFR.predicate = NSPredicate(format: "id == %d", message.roomId)
                
                guard let rooms = try? context.fetch(roomEntiryFR),
                      rooms.count == 1,
                      let room = rooms.first,
                      let user = self.getUsers(id: [message.fromUserId], context: context)?.first
                else {
                    promise(.failure(DatabseError.unknown))
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
