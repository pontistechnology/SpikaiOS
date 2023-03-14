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
    
//    func getMessages(forRoomId id: Int64) -> Future<[Message], Error>{
//        Future { [weak self] promise in
//            // TODO: - dbr
//            // fetch all messages, check string id,
//            // fetch message records
//            // maybe message records shouldnt be in message model
//            self?.coreDataStack.persistantContainer.performBackgroundTask { [weak self] context in
//                guard let self = self else { return }
//                let fetchRequest = MessageEntity.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "roomId == %@", "\(id)")
//
//                do {
//                    let messagesEntities = try context.fetch(fetchRequest)
//                    let messages = messagesEntities.map{ Message(messageEntity: $0)}
//                    promise(.success(messages.compactMap{$0}))
//                } catch {
//                    promise(.failure(DatabseError.requestFailed))
//                }
//            }
//        }
//    }
    
//    private func getMessageRecords(ids: [Int64], context: NSManagedObjectContext) -> MessageRecord {
//        let messageRecordsFR = MessageRecordEntity.fetchRequest()
//        messageRecordsFR.predicate = NSPredicate(format: "messageId IN %@", ids)
//        
//        
//    }

    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for message in messages {
                    let messageEntity = MessageEntity(message: message, context: context)
                }
                // todo add last timestamp
                
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
                let roomId = message.roomId
                let roomEntiryFR = RoomEntity.fetchRequest()
                roomEntiryFR.predicate = NSPredicate(format: "id == %d", roomId)
                
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
