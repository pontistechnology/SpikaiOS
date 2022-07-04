//
//  TestRepository+Sync.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.06.2022..
//

import Combine
import Foundation

extension TestRepository {
    func syncRooms(timestamp: Int64) -> AnyPublisher<SyncRoomsResponseModel, Error> {
        return Fail<SyncRoomsResponseModel, Error>(error: NetworkError.unknown).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func syncUsers(timestamp: Int64) -> AnyPublisher<SyncUsersResponseModel, Error> {
        return Fail<SyncUsersResponseModel, Error>(error: NetworkError.unknown).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func syncMessages(timestamp: Int64) -> AnyPublisher<SyncMessagesResponseModel, Error> {
        return Fail<SyncMessagesResponseModel, Error>(error: NetworkError.unknown).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func syncMessageRecords(timestamp: Int64) -> AnyPublisher<SyncMessageRecordsResponseModel, Error> {
        return Fail<SyncMessageRecordsResponseModel, Error>(error: NetworkError.unknown).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func setUsersSyncTimestamp(_ timestamp: Int64) {
        
    }
    
    func setRoomsSyncTimestamp(_ timestamp: Int64) {
        
    }
    
    func setMessagesSyncTimestamp(_ timestamp: Int64) {
        
    }
    
    func setMessageRecordsSyncTimestamp(_ timestamp: Int64) {
        
    }
    
    func getUsersSyncTimestamp() -> Int64 {
        4
    }
    
    func getRoomsSyncTimestamp() -> Int64 {
        4
    }
    
    func getMessagesSyncTimestamp() -> Int64 {
        4
    }
    
    func getMessageRecordsSyncTimestamp() -> Int64 {
        3
    }
}
