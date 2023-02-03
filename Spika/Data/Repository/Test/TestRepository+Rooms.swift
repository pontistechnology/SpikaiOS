////
////  TestRepository+Rooms.swift
////  Spika
////
////  Created by Nikola Barbarić on 07.03.2022..
////
//
//import Combine
//import Foundation
//import CoreData
//
//extension TestRepository {
//    func createOnlineRoom(name: String, avatarId: Int64?, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error> {
//        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func checkOnlineRoom(forUserId userId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error> {
//        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func createOnlineRoom(userId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error> {
//        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error> { //TODO: - remove
//        return Fail<GetAllRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func checkLocalRoom(forUserId id: Int64) -> Future<Room, Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//    func getRoomWithId(forRoomId id: Int64) -> Future<Room, Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//    func checkOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error> {
//        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func deleteOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<EmptyResponse, Error> {
//        return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func blockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error> {
//        return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//    }
//    
//    func unblockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error> {
//        return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//    }
//    
//    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//    func updateRoomUsers(room: Room) -> Future<Room, Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//    func roomVisited(roomId: Int64) {
//        
//    }
//    
//    func muteUnmuteRoom(roomId: Int64, mute: Bool) -> AnyPublisher<EmptyResponse,Error> {
//        return Fail<EmptyResponse, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func updateRoomUsers(roomId: Int64, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func updateRoomAdmins(roomId: Int64, adminIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func updateRoomAvatar(roomId: Int64, avatarId: Int64) -> AnyPublisher<CreateRoomResponseModel,Error> {
//        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    func deleteLocalRoom(roomId: Int64) -> Future<Bool, Error> {
//        return Future { promise in
//            promise(.failure(DatabseError.unknown))
//        }
//    }
//    
//}
