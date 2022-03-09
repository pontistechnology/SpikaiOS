//
//  AppRepository+Rooms.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import Combine

extension AppRepository {
    
    func createRoom(name: String, users: [AppUser]) -> AnyPublisher<CreateRoomResponseModel, Error> {

        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let userIds = users.map{$0.id}
        
        let resources = Resources<CreateRoomResponseModel, CreateRoomRequestModel>(
            path: Constants.Endpoints.createRoom,
            requestType: .POST,
            bodyParameters: CreateRoomRequestModel(name: name,
                                                   avatarUrl: nil,
                                                   userIds: userIds,
                                                   adminUserIds: nil),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func checkRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error>  {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<CheckRoomResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.checkRoom + "/" + String(userId),
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func createRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error> {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<CreateRoomResponseModel, CreateRoomRequestModel>(
            path: Constants.Endpoints.createRoom,
            requestType: .POST,
            bodyParameters: CreateRoomRequestModel(userIds: [userId]),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
}
