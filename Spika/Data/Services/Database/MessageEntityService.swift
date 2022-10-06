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
                    guard let roomId = messages[i].roomId else { continue }
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
    
    func saveMessageRecord(messageRecord: MessageRecord) -> Future<MessageRecord, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let messageFR = MessageEntity.fetchRequest()
                guard let messageId = messageRecord.messageId else { return }
                messageFR.predicate = NSPredicate(format: "id == %d", messageId)
                
                do {
                    let messages = try context.fetch(messageFR)
                    
                    if messages.count == 1 {
                        let recordEntity = MessageRecordEntity(record: messageRecord, context: context)
                        messages.first!.addToRecords(recordEntity)
                        do {
                            try context.save()
                            promise(.success(messageRecord))
                        } catch {
                            promise(.failure(DatabseError.savingError))
                        }
                    } else {
                        if messages.count != 0 {
                            print("more than one: ", messages)
                        }
                        promise(.failure(DatabseError.moreThanOne))
                    }
                } catch {
                    promise(.failure(DatabseError.requestFailed))
                }
            }
        }
    }
}
