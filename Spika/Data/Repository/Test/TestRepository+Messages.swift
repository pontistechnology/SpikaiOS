//
//  TestRepository+Messages.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import CoreData
import Combine

extension TestRepository {
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        Future { promise in
            promise(.failure(DatabseError.savingError))
        }
    }
    
    func sendMessage(body: MessageBody, type: MessageType, roomId: Int64, localId: String) -> AnyPublisher<SendMessageResponse, Error> {
       return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
    
    func sendDeliveredStatus(messageIds: [Int64]) -> AnyPublisher<DeliveredResponseModel, Error> {
        return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
    
    func getMessages(forRoomId: Int64) -> Future<[Message], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func updateLocalMessage(message: Message, localId: String) -> Future<Message, Error> {
        Future { p in
            p(.failure(DatabseError.requestFailed))
        }
    }
    
    func saveMessageRecord(messageRecord: MessageRecord) -> Future<MessageRecord, Error> {
        Future { p in
            p(.failure(DatabseError.unknown))
        }
    }
    
    func printAllMessages() {
        databaseService.messageEntityService.printAllMessages()
    }
}
