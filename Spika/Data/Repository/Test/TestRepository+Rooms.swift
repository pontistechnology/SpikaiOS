//
//  TestRepository+Rooms.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Combine
import Foundation

extension TestRepository {
    func createRoom(name: String, users: [AppUser]) -> AnyPublisher<CreateRoomResponseModel, Error> {
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
}
