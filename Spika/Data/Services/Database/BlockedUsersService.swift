//
//  BlockedUsersService.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import Foundation
import Combine

class BlockedUsersService {
    //MARK: Not thread safe, perhaps not necessary?
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
        let ids = Set(blockedUsers.map { $0.id })
        sharedPrefs.setValue(Array(ids), forKey: "blocked_user_ids")
        blockedUserIds.send(ids)
    }
    
    func updateConfirmedUsers(confirmedUsers: [User]) {
        let currentIds = self.confirmedUserIds.value ?? Set()
        let newIds = Set(confirmedUsers.map { $0.id })
        let union = newIds .union(currentIds)
        sharedPrefs.setValue(Array(union), forKey: "confirmed_user_ids")
        confirmedUserIds.send(union)
    }
    
}
