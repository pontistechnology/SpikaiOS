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
    
    func checkOnlineRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error> {
        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createOnlineRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error> {
        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error> {
        return Fail<GetAllRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func checkPrivateLocalRoom(forUserId id: Int) -> Future<Room, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func checkLocalRoom(withId roomId: Int) -> Future<Room, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func checkOnlineRoom(forRoomId roomId: Int) -> AnyPublisher<CheckRoomResponseModel, Error> {
        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
