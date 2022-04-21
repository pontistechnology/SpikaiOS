//
//  TestRepository+Messages.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import CoreData
import Combine

extension TestRepository {
    func saveMessage(message: Message) -> Future<(Message, String), Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func sendTextMessage(body: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error> {
       return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
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
}
