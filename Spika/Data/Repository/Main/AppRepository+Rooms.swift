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
    
    func createOnlineRoom(name: String, avatarId: Int64?, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
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
    
    func pinUnpinRoom(roomId: Int64, pin: Bool) -> AnyPublisher<EmptyResponse,Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let url = Constants.Endpoints.getAllRooms + "/\(roomId)" + (pin ? "/pin" : "/unpin")
        
        let resources = Resources<EmptyResponse, EmptyRequestBody>(
            path: url,
            requestType: .POST,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func updateRoom(roomId: Int64, action: UpdateRoomAction) -> AnyPublisher<CreateRoomResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
        let resources = Resources<CreateRoomResponseModel, EditRoomRequestModel>(
            path: url,
            requestType: .PUT,
            bodyParameters: EditRoomRequestModel(action: action),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
//    func updateRoomUsers(roomId: Int64, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        guard let accessToken = getAccessToken()
//        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        }
//        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
//        let resources = Resources<CreateRoomResponseModel, EditRoomRequestModel>(
//            path: url,
//            requestType: .PUT,
//            bodyParameters: EditRoomRequestModel(userIds: userIds),
//            httpHeaderFields: ["accesstoken" : accessToken])
//        return networkService.performRequest(resources: resources)
//    }
    
//    func updateRoomAdmins(roomId: Int64, adminIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        guard let accessToken = getAccessToken()
//        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        }
//        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
//        let resources = Resources<CreateRoomResponseModel, EditRoomAdminsRequestModel>(
//            path: url,
//            requestType: .PUT,
//            bodyParameters: EditRoomAdminsRequestModel(adminUserIds: adminIds),
//            httpHeaderFields: ["accesstoken" : accessToken])
//        return networkService.performRequest(resources: resources)
//    }
    
//    func updateRoomAvatar(roomId: Int64, avatarId: Int64) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        guard let accessToken = getAccessToken()
//        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        }
//        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
//        let resources = Resources<CreateRoomResponseModel, EditRoomAvatarRequestModel>(
//            path: url,
//            requestType: .PUT,
//            bodyParameters: EditRoomAvatarRequestModel(avatarFileId: avatarId),
//            httpHeaderFields: ["accesstoken" : accessToken])
//        return networkService.performRequest(resources: resources)
//    }
    
//    func updateRoomName(roomId: Int64, newName: String) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        guard let accessToken = getAccessToken()
//        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        }
//        let url = Constants.Endpoints.getAllRooms + "/\(roomId)"
//        let resources = Resources<CreateRoomResponseModel, EditRoomNameRequestModel>(
//            path: url,
//            requestType: .PUT,
//            bodyParameters: EditRoomNameRequestModel(name: newName),
//            httpHeaderFields: ["accesstoken" : accessToken])
//        return networkService.performRequest(resources: resources)
//    }
    
    func deleteOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<EmptyResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<EmptyResponse, EmptyRequestBody>(
            path: Constants.Endpoints.checkRoomForRoomId + "/" + String(roomId),
            requestType: .DELETE,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func leaveOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<CreateRoomResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.checkRoomForRoomId + "/" + String(roomId) + "/leave",
            requestType: .POST,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func blockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<EmptyResponse, BlockModel>(
            path: Constants.Endpoints.blocks,
            requestType: .POST,
            bodyParameters: BlockModel(blockedId: userId),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func unblockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<EmptyResponse, BlockModel>(
            path: Constants.Endpoints.blocks + "/userId/\(userId)",
            requestType: .DELETE,
            bodyParameters: BlockModel(blockedId: userId),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func getBlockedUsers() -> AnyPublisher<BlockedUsersResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<BlockedUsersResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<BlockedUsersResponseModel, BlockModel>(
            path: Constants.Endpoints.blocks,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func checkLocalPrivateRoom(forUserId id: Int64) -> Future<Room, Error>{
        return databaseService.getPrivateRoom(forUserId: id)
    }
    
    func getRoomWithId(forRoomId id: Int64) -> Future<Room, Error>{
        return databaseService.getRoom(forRoomId: id)
    }
    
    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error> {
        databaseService.saveRooms(rooms)
    }
    
    func updateRoomUsers(room: Room) -> Future<Room, Error> {
        databaseService.updateRoomUsers(room)
    }
    
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error> {
        databaseService.getRoom(forRoomId: roomId)
    }
    
    func deleteLocalRoom(roomId: Int64) -> Future<Bool, Error> {
        databaseService.deleteRoom(roomId: roomId)
    }
    
    func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]? {
        databaseService.getRoomUsers(roomId: roomId, context: context)
    }
    
    func generateRoomModelsWithUsers(context: NSManagedObjectContext, roomEntities: [RoomEntity]) -> Future<[Room], Error> {
        databaseService.generateRoomModelsWithUsers(roomEntities: roomEntities, context: context)
    }
}
