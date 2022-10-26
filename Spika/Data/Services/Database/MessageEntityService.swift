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
    
    func printAllMessages() {
        let messagesFR = MessageEntity.fetchRequest()
        let messages = try! coreDataStack.persistantContainer.viewContext.fetch(messagesFR)
        
        print("All messages count: ", messages.count)
        for message in messages {
            print("MESSAGE cD:", message.bodyText, message.id, "in room: ", message.roomId)
        }
        print("All messages: ", messages)
        
        
        let users = try! coreDataStack.persistantContainer.viewContext.fetch(UserEntity.fetchRequest())
        for user in users {
            print("USER: ", user.id, user.displayName)
        }
        
        let roomUsers = try! coreDataStack.persistantContainer.viewContext.fetch(RoomUserEntity.fetchRequest())
        for roomUser in roomUsers {
            print("ROOM USER: ", "userId: ",  roomUser.userId, " roomId: ", roomUser.roomId, " isAdmin: ", roomUser.isAdmin, " user: ", roomUser.user )
        }
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
                
                for i in 0..<messages.count {
                    let roomId = messages[i].roomId
                    let roomEntityFR = RoomEntity.fetchRequest()
                    roomEntityFR.predicate = NSPredicate(format: "id == %d", roomId)
                    do {
                        let rooms = try context.fetch(roomEntityFR)
                        if rooms.count == 1 {
                            let messageEntity = MessageEntity(message: messages[i], context: context)
                            rooms.first!.lastMessageTimestamp = messages[i].createdAt ?? 0
                            rooms.first!.addToMessages(messageEntity)
                        } else {
                            promise(.failure(DatabseError.moreThanOne))
                        }
                        
                    } catch {
                        promise(.failure(DatabseError.requestFailed))
                    }
                }
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
                for i in 0 ..< messageRecords.count {
                    let messageId = messageRecords[i].messageId
                    let messageFR = MessageEntity.fetchRequest()
                    messageFR.predicate = NSPredicate(format: "id == %d", messageId)
                    guard let messages = try? context.fetch(messageFR)
                    else {
                        print("DATABASE: Message is missing for MessageRecord.")
                        continue
                    }
                    if messages.count == 1 {
                        let recordEntity = MessageRecordEntity(record: messageRecords[i], context: context)
                        messages.first!.addToRecords(recordEntity)
                    } else {
//                        print("DATABASE: More than one message for messageRecord id.")
                        continue
                    }
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
    
    func getNotificationInfoForMessage(message: Message) -> Future<MessageNotificationInfo, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let roomId = message.roomId
                
                let roomEntiryFR = RoomEntity.fetchRequest()
                roomEntiryFR.predicate = NSPredicate(format: "id == %d", roomId)
                
                do {
                    let rooms = try context.fetch(roomEntiryFR)
                    if rooms.count == 1 {
                        let room = Room(roomEntity: rooms.first!)
                        let rU = room.users.first(where: { roomUser in
                            roomUser.userId == message.fromUserId
                        })
                        let info: MessageNotificationInfo
                        
                        if room.type == .privateRoom {
                            info = MessageNotificationInfo(title: rU?.user.getDisplayName() ?? "no name",
                                                           photoUrl: rU?.user.getAvatarUrl() ?? "",
                                                           messageText: message.body?.text ?? " ")
                        } else {
                            info = MessageNotificationInfo(title: room.name ?? "no name",
                                                           photoUrl: room.getAvatarUrl() ?? "",
                                                           messageText: "\(rU?.user.getDisplayName() ?? "_"): " + (message.body?.text ?? ""))
                        }
                        promise(.success(info))
                    }
                } catch {
                    promise(.failure(DatabseError.unknown))
                }
                
            }
        }

    }
    
}
