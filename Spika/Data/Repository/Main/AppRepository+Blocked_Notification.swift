//
//  AppRepository+Blocked_Notification.swift
//  Spika
//
//  Created by Vedran Vugrin on 26.01.2023..
//

import Foundation
import Combine


extension AppRepository {
    
    func serialWriteQueue() -> DispatchQueue {
        return DispatchQueue(label: "com.spika.blockeduserservice", attributes: .concurrent)
    }
    
    func updateBlockedUsers(users: [User]) {
    }
    
    func updateConfirmedUsers(confirmedUsers: [User]) {
    }
    
    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
        return CurrentValueSubject<Set<Int64>?,Never>(nil)
    }
    
    func confirmedUsersPublisher() -> CurrentValueSubject<Set<Int64>,Never> {
        return CurrentValueSubject<Set<Int64>,Never>([])
    }
    
    func setupContactSync() {}
    
    func syncContacts() {}
    
    func getPhoneContacts() -> Future<ContactFetchResult, Error> {
        Future() { _ in }
    }
    
}
