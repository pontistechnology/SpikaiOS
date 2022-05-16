//
//  TestRepository+Messages.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import CoreData
import Combine

extension TestRepository {
    func saveMessage(message: Message, roomId: Int) -> Future<Message, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func sendTextMessage(body: MessageBody, roomId: Int, localId: String) -> AnyPublisher<SendMessageResponse, Error> {
       return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
    
    func sendDeliveredStatus(messageIds: [Int]) -> AnyPublisher<DeliveredResponseModel, Error> {
        return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
    
    func getMessages(forRoomId: Int) -> Future<[Message], Error> {
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
    
    func getMessageRecordsAfter(timestamp: Int) -> AnyPublisher<MessageRecordSyncResponseModel, Error> {
        return Fail<MessageRecordSyncResponseModel, Error>(error: NetworkError.unknown)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
}
