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
    
    func syncAllMessages(timestamp: Int64) -> AnyPublisher<SyncMessagesResponseModel, Error> {
        guard let accessToken = getAccessToken() else {
            return Fail<SyncMessagesResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SyncMessagesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.syncAllMessages + "/\(timestamp)",
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
    func syncRooms() {
        let timestampNow = Date().currentTimeMillis()
        syncRooms(timestamp: getSyncTimestamp(for: .rooms)).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let rooms = response.data?.rooms else { return }
            self?.saveLocalRooms(rooms, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    private func saveLocalRooms(_ rooms: [Room], syncTimestamp: Int64) {
        saveLocalRooms(rooms: rooms).sink { _ in
            
        } receiveValue: { [weak self] rooms in
            self?.setSyncTimestamp(for: .rooms, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
}

extension AppRepository {
    func syncUsers() {
        let timestampNow = Date().currentTimeMillis()
        syncUsers(timestamp: getSyncTimestamp(for: .users)).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let users = response.data?.users else { return }
            self?.saveUsers(users, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    private func saveUsers(_ users: [User], syncTimestamp: Int64) {
        saveUsers(users).sink { _ in
            
        } receiveValue: { [weak self] users in
            self?.setSyncTimestamp(for: .users, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
    
//    func syncContacts() {
//        getPhoneContacts()
//            .flatMap { contacts in
//                let phoneHashes = contacts.fetchedContacts?.map { $0.telephone.getSHA256() } ?? [String]()
//                return self.postContacts(hashes: phoneHashes)
//            }
//            .sink(receiveCompletion: { _ in
//            }, receiveValue: { [weak self] response in
//                guard let users = response.data?.list else { return }
//                self?.saveUsers(users)
//            })
//            .store(in: &subs)
//    }
    
}

extension AppRepository {
    func syncMessageRecords() {
        let timestampNow = Date().currentTimeMillis()
        syncMessageRecords(timestamp: getSyncTimestamp(for: .messageRecords)).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let records = response.data?.messageRecords else { return }
            self?.saveMessageRecords(records, syncTimestamp: timestampNow)
        }.store(in: &subs)
    }
    
    private func saveMessageRecords(_ records: [MessageRecord], syncTimestamp: Int64) {
        print("SSE: message records recieved: ", records.count)
        saveMessageRecords(records).sink { _ in
            
        } receiveValue: { [weak self] _ in
            self?.setSyncTimestamp(for: .messageRecords, timestamp: syncTimestamp)
        }.store(in: &subs)
    }
}

extension AppRepository {
    func syncMessages() {
        let timeStampNow = Date().currentTimeMillis()
        syncAllMessages(timestamp: getSyncTimestamp(for: .messages)).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let messages = response.data?.messages else { return }
            self?.saveMessages(messages, syncTimestamp: timeStampNow)
        }.store(in: &subs)
    }
    
    private func saveMessages(_ messages: [Message], syncTimestamp: Int64) {
        saveMessages(messages).sink { _ in
            
        } receiveValue: { [weak self] isSaved in
            self?.setSyncTimestamp(for: .messages, timestamp: syncTimestamp)
            self?.sendDeliveredStatus(messageIds: messages.compactMap{ $0.id } )
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





