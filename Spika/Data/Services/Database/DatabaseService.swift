//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation

enum DatabseError: Error {
    case requestFailed, noSuchRecord, unknown

    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        }
  }
}

class DatabaseService {
    let userEntityService: UserEntityService
    let chatEntityService: ChatEntityService
    let messageEntityService: MessageEntityService
    
    init(userEntityService: UserEntityService, chatEntityService: ChatEntityService, messageEntityService: MessageEntityService) {
        self.userEntityService = userEntityService
        self.chatEntityService = chatEntityService
        self.messageEntityService = messageEntityService
    }
    
}
