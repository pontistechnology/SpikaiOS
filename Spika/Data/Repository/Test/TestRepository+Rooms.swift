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
    func createRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error> {
        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func checkRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error> {
        return Fail<CheckRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error> {
        return Fail<CreateRoomResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error> {
        return Fail<GetAllRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func checkPrivateLocalRoom(forId id: Int) -> Future<NSManagedObjectID, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
}
