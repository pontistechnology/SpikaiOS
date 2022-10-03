import Combine
import Foundation


extension AppRepository {
    func syncRooms(timestamp: Int64) -> AnyPublisher<SyncRoomsResponseModel, Error> {
        
        guard let accessToken = getAccessToken() else { return
            Fail<SyncRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncRoomsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncRooms + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    
    
    
    
    
    
    func syncUsers(timestamp: Int64) -> AnyPublisher<SyncUsersResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncUsersResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncUsersResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncUsers + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        
        return networkService.performRequest(resources: resources)
    }
    
    
    
    
    
    
    
    
    func syncMessages() -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncMessages,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    
    
    
    
    
    
    func syncMessageRecords(timestamp: Int64) -> AnyPublisher<SyncMessageRecordsResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessageRecordsResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessageRecordsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncMessageRecords + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        
        return networkService.performRequest(resources: resources)
    }
    
    func getRoomsSyncTimestamp() -> Int64 {
        Int64(userDefaults.integer(forKey: Constants.UserDefaults.roomsSyncTimestamp))
    }
    
    func getUsersSyncTimestamp() -> Int64 {
        Int64(userDefaults.integer(forKey: Constants.UserDefaults.usersSyncTimestamp))
    }
    
    func getMessagesSyncTimestamp() -> Int64 {
        Int64(userDefaults.integer(forKey: Constants.UserDefaults.messagesSyncTimestamp))
    }
    
    func getMessageRecordsSyncTimestamp() -> Int64 {
        Int64(userDefaults.integer(forKey: Constants.UserDefaults.messageRecordsSyncTimestamp))
    }
    
    func setRoomsSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: Constants.UserDefaults.roomsSyncTimestamp)
    }
    
    func setUsersSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: Constants.UserDefaults.usersSyncTimestamp)
    }
    
    func setMessagesSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: Constants.UserDefaults.messagesSyncTimestamp)
    }
    
    func setMessageRecordsSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: Constants.UserDefaults.messageRecordsSyncTimestamp)
    }
}

