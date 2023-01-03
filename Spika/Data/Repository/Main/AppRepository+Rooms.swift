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
    
    func createOnlineRoom(name: String, avatarId: Int64?, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error> {
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
                                                   avatarFileId: avatarId,
                                                   userIds: userIds,
                                                   adminUserIds: nil),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func checkOnlineRoom(forUserId userId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>  {
        guard let accessToken = getAccessToken()
        else {return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<CheckRoomResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.checkRoomForUserId + "/" + String(userId),
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func checkOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>  {
        guard let accessToken = getAccessToken()
        else {return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<CheckRoomResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.checkRoomForRoomId + "/" + String(roomId),
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func createOnlineRoom(userId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error> {
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
    
    func muteUnmuteRoom(roomId: Int64, mute: Bool) -> AnyPublisher<EmptyResponse,Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let url = Constants.Endpoints.getAllRooms + "/\(roomId)" + (mute ? "/mute" : "/unmute")
        
        let resources = Resources<EmptyResponse, EmptyRequestBody>(
            path: url,
            requestType: .POST,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func updateRoomUsers(roomId: Int64, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
        let resources = Resources<CreateRoomResponseModel, EditRoomUsersRequestModel>(
            path: url,
            requestType: .PUT,
            bodyParameters: EditRoomUsersRequestModel(userIds: userIds),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func updateRoomAdmins(roomId: Int64, adminIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
        let resources = Resources<CreateRoomResponseModel, EditRoomAdminsRequestModel>(
            path: url,
            requestType: .PUT,
            bodyParameters: EditRoomAdminsRequestModel(adminUserIds: adminIds),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func checkLocalRoom(forUserId id: Int64) -> Future<Room, Error>{
        return databaseService.roomEntityService.getRoom(forUserId: id)
    }
    
    func getRoomWithId(forRoomId id: Int64) -> Future<Room, Error>{
        return databaseService.roomEntityService.getRoom(forRoomId: id)
    }
    
    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error> {
        databaseService.roomEntityService.saveRooms(rooms)
    }
    
    func updateRoomUsers(room: Room) -> Future<Room, Error> {
        databaseService.roomEntityService.updateRoomUsers(room)
    }
    
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error> {
        databaseService.roomEntityService.checkLocalRoom(withId: roomId)
    }
    
    func roomVisited(roomId: Int64) {
        databaseService.roomEntityService.roomVisited(roomId: roomId)
    }
}
