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
    
    
    
    
    
    
    
    
    func syncMessages(timestamp: Int64) -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncMessages + "/\(timestamp)",
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
    
    func getSyncTimestamp(for type: SyncType) -> Int64 {
        switch type {
            
        case .rooms:
            return Int64(userDefaults.integer(forKey: Constants.UserDefaults.roomsSyncTimestamp))
        case .users:
            return Int64(userDefaults.integer(forKey: Constants.UserDefaults.usersSyncTimestamp))
        case .messages:
            let timestamp = Int64(userDefaults.integer(forKey: Constants.UserDefaults.messagesSyncTimestamp))
            return timestamp == 0 ? Date().currentTimeMillis() : timestamp
        case .messageRecords:
            let timestamp = Int64(userDefaults.integer(forKey: Constants.UserDefaults.messageRecordsSyncTimestamp))
            return timestamp == 0 ? Date().currentTimeMillis() : timestamp
        }
    }
    
    func setSyncTimestamp(for type: SyncType, timestamp: Int64) {
        switch type {
            
        case .users:
            userDefaults.set(timestamp, forKey: Constants.UserDefaults.usersSyncTimestamp)
        case .rooms:
            userDefaults.set(timestamp, forKey: Constants.UserDefaults.roomsSyncTimestamp)
        case .messageRecords:
            userDefaults.set(timestamp, forKey: Constants.UserDefaults.messageRecordsSyncTimestamp)
        case .messages:
            userDefaults.set(timestamp, forKey: Constants.UserDefaults.messagesSyncTimestamp)
        }
    }
}

