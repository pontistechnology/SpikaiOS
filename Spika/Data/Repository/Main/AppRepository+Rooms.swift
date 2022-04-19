//
//  AppRepository+Rooms.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import Combine
import CoreData

extension AppRepository {
    
    // MARK: UserDefaults
    
    
    // MARK: Network
    
    func createRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error> {

        guard let accessToken = getAccessToken()
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
        guard let accessToken = getAccessToken()
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
        guard let accessToken = getAccessToken()
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
    
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<GetAllRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<GetAllRoomsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.getAllRooms,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func checkPrivateLocalRoom(forId id: Int) -> Future<NSManagedObjectID, Error>{
        return databaseService.roomEntityService.getPrivateRoom(forId: id)
    }
    
    func saveRoom(room: Room) -> Future<NSManagedObjectID, Error> {
        return databaseService.roomEntityService.saveRoom(room)
    }
}
