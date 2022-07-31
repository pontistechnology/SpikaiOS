//
//  TestRepository+Rooms.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Combine
import Foundation
import CoreData

extension TestRepository {
    func createOnlineRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error> {
        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func checkOnlineRoom(forUserId userId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error> {
        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createOnlineRoom(userId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error> {
        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error> {
        return Fail<GetAllRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func checkLocalRoom(forUserId id: Int64) -> Future<Room, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func checkOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error> {
        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func roomVisited(roomId: Int64) {
        
    }
}
