//
//  SyncService.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.05.2024..
//

import Combine
import Foundation

enum SyncStatus {
    case resting
    case syncingMessages(String)
    case syncingUsers(String)
    case syncingChats(String)
    
    // TODO: - implmenetation
    var text: String { return "" }
}

class SyncService {
    static let shared = SyncService()
    
    private init () {}
    
    let c = CurrentValueSubject<SyncStatus, Never>(.resting)
}
