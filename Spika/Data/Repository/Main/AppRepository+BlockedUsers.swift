//
//  AppRepository+BlockedUsers.swift
//  Spika
//
//  Created by Vedran Vugrin on 18.01.2023..
//

import Foundation
import Combine

extension AppRepository {
    
    func loadStoredBlockedUserValues() {
        let blockedArray = self.userDefaults.value(forKey: "blocked_user_ids") as? [Int64]
        self.blockedUserIds.send(Set(blockedArray ?? []))
        
        let confirmedArray = self.userDefaults.value(forKey: "confirmed_user_ids") as? [Int64]
        self.confirmedUserIds.send(Set(confirmedArray ?? []))
    }
    
    func updateBlockedUsers(users: [User]) {
        self.writeQueue.async {
            let ids = Set(users.map { $0.id })
            self.userDefaults.setValue(Array(ids), forKey: "blocked_user_ids")
            self.blockedUserIds.send(ids)
        }
    }
    
    func updateConfirmedUsers(confirmedUsers: [User]) {
        self.writeQueue.async {
            let currentIds = self.confirmedUserIds.value ?? Set()
            let newIds = Set(confirmedUsers.map { $0.id })
            let union = newIds .union(currentIds)
            self.userDefaults.setValue(Array(union), forKey: "confirmed_user_ids")
            self.confirmedUserIds.send(union)
        }
    }
    
    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
        return self.blockedUserIds
    }
    
    func confirmedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
        return self.confirmedUserIds
    }
    
}
