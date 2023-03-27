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
    
    func syncModifiedMessages(timestamp: Int64) -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncModifiedMessages + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func syncUndeliveredMessages() -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncUndeliveredMessages,
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
            return Int64(userDefaults.integer(forKey: Constants.Database.roomsSyncTimestamp))
        case .users:
            return Int64(userDefaults.integer(forKey: Constants.Database.usersSyncTimestamp))
        case .messages:
            return Int64(userDefaults.integer(forKey: Constants.Database.messagesSyncTimestamp))
        case .messageRecords:
            return Int64(userDefaults.integer(forKey: Constants.Database.messageRecordsSyncTimestamp))
        }
    }
    
    func setSyncTimestamp(for type: SyncType, timestamp: Int64) {
        switch type {
        case .users:
            userDefaults.set(timestamp, forKey: Constants.Database.usersSyncTimestamp)
        case .rooms:
            userDefaults.set(timestamp, forKey: Constants.Database.roomsSyncTimestamp)
        case .messageRecords:
            userDefaults.set(timestamp, forKey: Constants.Database.messageRecordsSyncTimestamp)
        case .messages:
            userDefaults.set(timestamp, forKey: Constants.Database.messagesSyncTimestamp)
        }
    }
}

