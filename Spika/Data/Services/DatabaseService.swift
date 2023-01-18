//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//
import CoreData
import Combine

enum DatabseError: Error {
    case requestFailed, noSuchRecord, unknown, moreThanOne, savingError
    
    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        case .moreThanOne: return "More than one record."
        case .savingError: return "Saving error."
        }
    }
}

class DatabaseService {
    let userEntityService: UserEntityService
    let chatEntityService: ChatEntityService
    let messageEntityService: MessageEntityService
    let roomEntityService: RoomEntityService
    let coreDataStack: CoreDataStack
    
    init(userEntityService: UserEntityService, chatEntityService: ChatEntityService, messageEntityService: MessageEntityService, roomEntityService: RoomEntityService, coreDataStack: CoreDataStack, userDefaults: UserDefaults) {
        self.userEntityService = userEntityService
        self.chatEntityService = chatEntityService
        self.messageEntityService = messageEntityService
        self.roomEntityService = roomEntityService
        self.coreDataStack = coreDataStack
    }
}
