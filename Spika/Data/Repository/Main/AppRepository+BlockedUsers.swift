//
//  AppRepository+BlockedUsers.swift
//  Spika
//
//  Created by Vedran Vugrin on 18.01.2023..
//

import Foundation
import Combine
import Swinject

extension AppRepository {
    
    func serialWriteQueue() -> DispatchQueue {
        return Assembler.sharedAssembler.resolver.resolve(DispatchQueue.self)!
    }
    
    func updateBlockedUsers(users: [User]) {
        self.serialWriteQueue().async {
            let ids = Set(users.map { $0.id })
            self.userDefaults.setValue(Array(ids), forKey: "blocked_user_ids")
            self.blockedUsersPublisher().send(ids)
        }
    }
    
    func updateConfirmedUsers(confirmedUsers: [User]) {
        self.serialWriteQueue().async {
            let currentIds = self.confirmedUsersPublisher().value
            let newIds = Set(confirmedUsers.map { $0.id })
            let union = newIds .union(currentIds)
            self.userDefaults.setValue(Array(union), forKey: "confirmed_user_ids")
            self.confirmedUsersPublisher().send(union)
        }
    }
    
    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
        return Assembler.sharedAssembler.resolver.resolve(CurrentValueSubject<Set<Int64>?,Never>.self)!
    }
    
    func confirmedUsersPublisher() -> CurrentValueSubject<Set<Int64>,Never> {
        return Assembler.sharedAssembler.resolver.resolve(CurrentValueSubject<Set<Int64>,Never>.self)!
    }
    
}
