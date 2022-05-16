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
    
    func getMessages(forRoomId id: Int) -> Future<[Message], Error>{
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
    func saveMessage(message: Message, roomId: Int) -> Future<Message, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.coreDataStack.persistantContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let roomEntityFR = RoomEntity.fetchRequest()
                roomEntityFR.predicate = NSPredicate(format: "id == %d", roomId)
                do {
                    let rooms = try context.fetch(roomEntityFR)
                    if rooms.count == 1 {
                        let messageEntity = MessageEntity(message: message, context: context)
                        rooms.first!.addToMessages(messageEntity)
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
                        promise(.failure(DatabseError.moreThanOne))
                    }
                } catch {
                    promise(.failure(DatabseError.requestFailed))
                }
            }
        }
    }
}
