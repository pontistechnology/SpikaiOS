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
        
        let userIds = users.map{$0.id ?? 1}
        
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
}
