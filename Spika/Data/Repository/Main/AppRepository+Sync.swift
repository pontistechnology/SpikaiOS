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
            
        case .users:
            return Int64(userDefaults.integer(forKey: Constants.UserDefaults.usersSyncTimestamp))
        case .rooms:
            return Int64(userDefaults.integer(forKey: Constants.UserDefaults.roomsSyncTimestamp))
        case .messageRecords:
            return Int64(userDefaults.integer(forKey: Constants.UserDefaults.messageRecordsSyncTimestamp))
        case .messages:
            if 0 == Int64(userDefaults.integer(forKey: Constants.UserDefaults.messagesSyncTimestamp)) {
                return Date().currentTimeMillis()
            } else {
                return Int64(userDefaults.integer(forKey: Constants.UserDefaults.messagesSyncTimestamp))
            }
        }
    }
    
    func setSyncTimestamp(for type: SyncType) {
        let now = Date().currentTimeMillis()
        switch type {
            
        case .users:
            userDefaults.set(now, forKey: Constants.UserDefaults.usersSyncTimestamp)
        case .rooms:
            userDefaults.set(now, forKey: Constants.UserDefaults.roomsSyncTimestamp)
        case .messageRecords:
            userDefaults.set(now, forKey: Constants.UserDefaults.messageRecordsSyncTimestamp)
        case .messages:
            userDefaults.set(now, forKey: Constants.UserDefaults.messagesSyncTimestamp)
        }
    }
}

