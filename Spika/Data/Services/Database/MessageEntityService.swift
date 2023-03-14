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
    
    func getMessages(forRoomId id: Int64) -> Future<[Message], Error>{
        Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                let fetchRequest = MessageEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.roomId), "\(id)")
                
                do {
                    let messagesEntities = try context.fetch(fetchRequest)
                    let messages = messagesEntities.map{ Message(messageEntity: $0)}
                    promise(.success(messages.compactMap{$0}))
                } catch {
                    promise(.failure(DatabseError.requestFailed))
                }
            }
        }
    }

    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for message in messages {
                    let messageEntity = MessageEntity(message: message, context: context)
                }
                
//                for i in 0..<messages.count {
//                    let roomId = messages[i].roomId
//                    let roomEntityFR = RoomEntity.fetchRequest()
//                    roomEntityFR.predicate = NSPredicate(format: "id == %d", roomId)
//                    do {
//                        let rooms = try context.fetch(roomEntityFR)
//                        if rooms.count == 1 {
//                            let messageEntity = MessageEntity(message: messages[i], context: context)
//                            rooms.first!.lastMessageTimestamp = messages[i].createdAt
//                            rooms.first!.addToMessages(messageEntity)
//                        } else {
//                            print(" 0 or more than one room for roomId: ", roomId, "and message is: ", messages[i].body?.text)
//                            promise(.failure(DatabseError.moreThanOne))
//                        }
//
//                    } catch {
//                        promise(.failure(DatabseError.requestFailed))
//                    }
//                }
                
                do {
                    try context.save()
                    promise(.success(messages))
                } catch {
                    promise(.failure(DatabseError.savingError))
                }
            }
        }
    }
    // TODO: - check for failures
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for messageRecord in messageRecords {
                    let recordEntity = MessageRecordEntity(record: messageRecord,
                                                           context: context)
                }
                
                
//                var savedRecords: [MessageRecord] = []
//                messageRecords.forEach({ record in
//                    let messageId = record.messageId
//                    let messageFR = MessageEntity.fetchRequest()
//                    messageFR.predicate = NSPredicate(format: "id == '\(messageId)'")
//
//                    guard let messages = try? context.fetch(messageFR)
//                    else {
//                        print("DATABASE: Message fetch error?.")
//                        return
//                    }
//                    guard messages.count == 1 else {
//                        print("0 or 1+ records for message id.")
//                        return
//                    }
//                    let recordEntity = MessageRecordEntity(record: record, context: context)
//                    messages.first?.addToRecords(recordEntity)
//                    savedRecords.append(record)
//                })
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
