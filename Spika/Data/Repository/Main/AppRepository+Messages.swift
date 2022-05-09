//
//  AppRepository+Messages.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import CoreData
import Combine

extension AppRepository {
    
    // MARK: UserDefaults
    
    
    // MARK: Network
    
    func sendTextMessage(body: MessageBody, roomId: Int, localId: String) -> AnyPublisher<SendMessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendMessageResponse, SendMessageRequest>(
            path: Constants.Endpoints.sendMessage,
            requestType: .POST,
            bodyParameters: SendMessageRequest(roomId: roomId,
                                               type: MessageType.text.rawValue,
                                               body: body,
                                               localId: localId),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func sendDeliveredStatus(messageIds: [Int]) -> AnyPublisher<DeliveredResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<DeliveredResponseModel, DeliveredRequestModel>(
            path: Constants.Endpoints.deliveredStatus,
            requestType: .POST,
            bodyParameters: DeliveredRequestModel(messagesIds: messageIds),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func saveMessage(message: Message, roomId: Int) -> Future<Message, Error> {
        return databaseService.messageEntityService.saveMessage(message: message, roomId: roomId)
    }
    
    func getMessages(forRoomId roomId: Int) -> Future<[Message], Error> {
        self.databaseService.messageEntityService.getMessages(forRoomId: roomId)
    }

}
