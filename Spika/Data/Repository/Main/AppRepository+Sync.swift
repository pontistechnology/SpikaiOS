//
//  AppRepository+Device.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.04.2022..
//

import Contacts
import CoreTelephony
import Combine
import Foundation

// network calls
private extension AppRepository {
    func syncRooms(timestamp: Int64, page: Int) -> AnyPublisher<SyncRoomsResponseModel, Error> {
        
        guard let accessToken = getAccessToken() else { return
            Fail<SyncRoomsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncRoomsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncRooms + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page" : page])
        
        return networkService.performRequest(resources: resources)
    }
    
    func syncUsers(timestamp: Int64, page: Int) -> AnyPublisher<SyncUsersResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncUsersResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncUsersResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncUsers + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page" : page])
        
        
        return networkService.performRequest(resources: resources)
    }
    
    func syncAllMessages(timestamp: Int64, page: Int) -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else {
            return Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncAllMessages + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page" : page])
        
        return networkService.performRequest(resources: resources)
    }
    
    func syncMessageRecords(timestamp: Int64, page: Int) -> AnyPublisher<SyncMessageRecordsResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<SyncMessageRecordsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessageRecordsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncMessageRecords + "/\(timestamp)",
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page" : page])
        
        
        return networkService.performRequest(resources: resources)
    }
}

extension AppRepository {
    
    func refreshUnreadCounts() {
        getUnreadCounts().sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let counts = response.data?.unreadCounts else { return }
            self?.updateUnreadCounts(unreadCounts: counts)
            self?.notificationHelpers.removeNotificationsThatAreNot(roomIds: counts.map({ $0.roomId }))
        }.store(in: &subs)
    }
    
    private func getUnreadCounts() -> AnyPublisher<UnreadCountResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<UnreadCountResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<UnreadCountResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.getUnreadCount,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func updateUnreadCounts(unreadCounts: [UnreadCount]) {
        databaseService.updateUnreadCounts(unreadCounts)
    }
    
    func updateUnreadCountToZeroFor(roomId: Int64) {
        databaseService.resetUnreadCount(roomId)
    }
    
    private func getSyncTimestamp(for type: SyncType) -> Int64 {
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
    
    private func setSyncTimestamp(for type: SyncType, timestamp: Int64) {
        switch type {
        case .users:
            userDefaults.set(timestamp, forKey: Constants.Database.usersSyncTimestamp)
        case .rooms:
            userDefaults.set(timestamp, forKey: Constants.Database.roomsSyncTimestamp)
        case .messages:
            userDefaults.set(timestamp, forKey: Constants.Database.messagesSyncTimestamp)
        case .messageRecords:
            userDefaults.set(timestamp, forKey: Constants.Database.messageRecordsSyncTimestamp)
        }
    }
}

extension AppRepository {
    func syncRooms(page: Int, startingTimestamp: Int64) {
        syncRooms(timestamp: getSyncTimestamp(for: .rooms), page: page).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.list else { return }
            if let hasNext = response.data?.hasNext, hasNext {
                self?.syncRooms(page: page + 1, startingTimestamp: startingTimestamp)
                self?.saveLocalRooms(rooms, syncTimestamp: nil)
            } else {
                self?.saveLocalRooms(rooms, syncTimestamp: startingTimestamp)
            }
        }.store(in: &subs)
    }
    
    private func saveLocalRooms(_ rooms: [Room], syncTimestamp: Int64?) {
        saveLocalRooms(rooms: rooms).sink { _ in
            
        } receiveValue: { [weak self] rooms in
            guard let syncTimestamp else { return }
            self?.setSyncTimestamp(for: .rooms, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
}

extension AppRepository {
    func syncUsers(page: Int, startingTimestamp: Int64) {
        syncUsers(timestamp: getSyncTimestamp(for: .users), page: page).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let users = response.data?.list else { return }
            if let hasNext = response.data?.hasNext, hasNext {
                self?.syncUsers(page: page+1, startingTimestamp: startingTimestamp)
                self?.saveUsers(users, syncTimestamp: nil)
            } else {
                self?.saveUsers(users, syncTimestamp: startingTimestamp)
            }
        }.store(in: &subs)
    }
    
    private func saveUsers(_ users: [User], syncTimestamp: Int64?) {
        saveUsers(users).sink { _ in
            
        } receiveValue: { [weak self] users in
            guard let syncTimestamp else { return }
            self?.setSyncTimestamp(for: .users, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
    
}

extension AppRepository {
    func syncMessageRecords(page: Int, startingTimestamp: Int64) {
        syncMessageRecords(timestamp: getSyncTimestamp(for: .messageRecords), page: page).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let records = response.data?.list else { return }
            if let hasNext = response.data?.hasNext, hasNext {
                self?.syncMessageRecords(page: page+1, startingTimestamp: startingTimestamp)
                self?.saveMessageRecords(records, syncTimestamp: nil)
            } else {
                self?.saveMessageRecords(records, syncTimestamp: startingTimestamp)
            }
        }.store(in: &subs)
    }
    
    private func saveMessageRecords(_ records: [MessageRecord], syncTimestamp: Int64?) {
        print("SSE: message records recieved: ", records.count)
        saveMessageRecords(records).sink { _ in
            
        } receiveValue: { [weak self] _ in
            guard let syncTimestamp else { return }
            self?.setSyncTimestamp(for: .messageRecords, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
}

extension AppRepository {
    func syncMessages(page: Int, startingTimestamp: Int64) {
        syncAllMessages(timestamp: getSyncTimestamp(for: .messages), page: page).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let messages = response.data?.list else { return }
            if let hasNext = response.data?.hasNext, hasNext {
                self?.syncMessages(page: page+1, startingTimestamp: startingTimestamp)
                self?.saveMessages(messages, syncTimestamp: nil)
            } else {
                self?.saveMessages(messages, syncTimestamp: startingTimestamp)
            }
        }.store(in: &subs)
    }
    
    private func saveMessages(_ messages: [Message], syncTimestamp: Int64?) {
        saveMessages(messages).sink { _ in
            
        } receiveValue: { [weak self] isSaved in
            _ = self?.sendDeliveredStatus(messageIds: messages.compactMap{ $0.id } )
            guard let syncTimestamp else { return }
            self?.setSyncTimestamp(for: .messages, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
}

extension AppRepository {
    func syncBlockedList() {
        getBlockedUsers()
            .sink { _ in
            } receiveValue: { [weak self] response in
                self?.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subs)
    }
}





