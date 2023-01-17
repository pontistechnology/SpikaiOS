//
//  BlockedUsersService.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import Foundation
import Combine

class BlockedUsersService {
    
    private let writeQueue = DispatchQueue(label: "com.spika.blockeduserservice", attributes: .concurrent)
    
    let blockedUserIds = CurrentValueSubject<Set<Int64>?,Never>(nil)
    
    let confirmedUserIds = CurrentValueSubject<Set<Int64>?,Never>(nil)
    
    let sharedPrefs: UserDefaults
    
    init(sharedPrefs: UserDefaults) {
        self.sharedPrefs = sharedPrefs
        
        let blockedArray = sharedPrefs.value(forKey: "blocked_user_ids") as? [Int64]
        self.blockedUserIds.send(Set(blockedArray ?? []))
        
        let confirmedArray = sharedPrefs.value(forKey: "confirmed_user_ids") as? [Int64]
        self.confirmedUserIds.send(Set(confirmedArray ?? []))
    }
    
    func updateBlockedUsers(blockedUsers: [User]) {
        writeQueue.async {
            let ids = Set(blockedUsers.map { $0.id })
            self.sharedPrefs.setValue(Array(ids), forKey: "blocked_user_ids")
            self.blockedUserIds.send(ids)
        }
    }
    
    func updateConfirmedUsers(confirmedUsers: [User]) {
        writeQueue.async {
            let currentIds = self.confirmedUserIds.value ?? Set()
            let newIds = Set(confirmedUsers.map { $0.id })
            let union = newIds .union(currentIds)
            self.sharedPrefs.setValue(Array(union), forKey: "confirmed_user_ids")
            self.confirmedUserIds.send(union)
        }
    }
    
}
