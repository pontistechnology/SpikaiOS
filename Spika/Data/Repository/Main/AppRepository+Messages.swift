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
    
    func sendMessage(body: RequestMessageBody, type: MessageType, roomId: Int64, localId: String, replyId: Int64?) -> AnyPublisher<SendMessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendMessageResponse, SendMessageRequest>(
            path: Constants.Endpoints.sendMessage,
            requestType: .POST,
            bodyParameters: SendMessageRequest(roomId: roomId,
                                               type: type.rawValue,
                                               body: body,
                                               localId: localId,
                                               replyId: replyId),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func deleteMessage(messageId: Int64, target: DeleteMessageTarget) -> AnyPublisher<SendMessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendMessageResponse, EmptyRequestBody>(
            path: Constants.Endpoints.sendMessage + "/\(messageId)",
            requestType: .DELETE,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["target" : target.rawValue])
        
        return networkService.performRequest(resources: resources)
    }
    
    func sendDeliveredStatus(messageIds: [Int64]) -> AnyPublisher<DeliveredResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
//        print("message id u repos: ", messageIds)
        
        let resources = Resources<DeliveredResponseModel, DeliveredRequestModel>(
            path: Constants.Endpoints.deliveredStatus,
            requestType: .POST,
            bodyParameters: DeliveredRequestModel(messagesIds: messageIds),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func sendSeenStatus(roomId: Int64) -> AnyPublisher<SeenResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {
            return Fail(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SeenResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.seenStatus.replacingOccurrences(of: "roomId", with: "\(roomId)"),
            requestType: .POST,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func printAllMessages() {
//        databaseService.messageEntityService.printAllMessages()
    }
    
    func sendReaction(messageId: Int64, reaction: String) -> AnyPublisher<SendReactionResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {
            return Fail(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendReactionResponseModel, SendReactionRequestModel>(
            path: Constants.Endpoints.messageRecords,
            requestType: .POST,
            bodyParameters: SendReactionRequestModel(messageId: messageId,
                                                     type: .reaction,
                                                     reaction: reaction),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
//    func getMessageRecordsAfter(timestamp: Int) -> AnyPublisher<MessageRecordSyncResponseModel, Error> {
//        guard let accessToken = getAccessToken()
//        else {
//            return Fail<MessageRecordSyncResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        }
//        
//        let resources = Resources<MessageRecordSyncResponseModel, EmptyRequestBody>(
//            path: Constants.Endpoints.messageRecordSync + "\(timestamp)",
//            requestType: .GET,
//            bodyParameters: nil,
//            httpHeaderFields: ["accesstoken" : accessToken])
//        
//        return networkService.performRequest(resources: resources)
//    }
    
    // MARK: Database
    
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        return databaseService.messageEntityService.saveMessages(messages)
    }
    
//    func getMessages(forRoomId roomId: Int64) -> Future<[Message], Error> {
//        self.databaseService.messageEntityService.getMessages(forRoomId: roomId)
//    }

    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error> {
        self.databaseService.messageEntityService.saveMessageRecords(messageRecords)
    }
    
    func getNotificationInfoForMessage(_ message: Message) -> Future<MessageNotificationInfo, Error> {
        self.databaseService.messageEntityService.getNotificationInfoForMessage(message: message)
    }

}
