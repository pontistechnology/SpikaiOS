//
//  AppRepository+Messages.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation
import Combine

extension AppRepository {
    
    // MARK: UserDefaults
    
    
    // MARK: Network
    
    func sendTextMessage(message: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error> {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendMessageResponse, SendMessageRequest>(
            path: Constants.Endpoints.sendMessage,
            requestType: .POST,
            bodyParameters: SendMessageRequest(roomId: roomId, type: "text", message: message),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func saveMessage(_ message: LocalMessage) -> Future<LocalMessage, Error> {
//        return databaseService.messageEntityService.saveMessage(message)
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        } // TODO: Change
    }
}
