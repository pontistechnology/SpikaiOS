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
    // TODO: use roomId from message?
    func saveMessage(message: Message, roomId: Int64) -> Future<Message, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let roomEntityFR = RoomEntity.fetchRequest()
                roomEntityFR.predicate = NSPredicate(format: "id == %d", roomId)
                do {
                    let rooms = try context.fetch(roomEntityFR)
                    print("RC: ", rooms.count)
                    if rooms.count == 1 {
                        let messageEntity = MessageEntity(message: message, context: context)
                        rooms.first!.lastMessageTimestamp = Int64(message.createdAt ?? 0)
                        rooms.first!.addToMessages(messageEntity)
                        print("saved message:", message)
                        do {
                            try context.save()
                            promise(.success(Message(messageEntity: messageEntity)))
                        } catch {
                            promise(.failure(DatabseError.savingError))
                        }
                    } else {
                        promise(.failure(DatabseError.moreThanOne))
                    }
                } catch {
                    promise(.failure(DatabseError.requestFailed))
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
