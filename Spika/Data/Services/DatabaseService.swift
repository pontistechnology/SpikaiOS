//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Combine

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
    let testEntityService: TestEntityService
    let roomEntityService: RoomEntityService
    
    init(userEntityService: UserEntityService, chatEntityService: ChatEntityService, messageEntityService: MessageEntityService, testEntityService: TestEntityService, roomEntityService: RoomEntityService) {
        self.userEntityService = userEntityService
        self.chatEntityService = chatEntityService
        self.messageEntityService = messageEntityService
        self.testEntityService = testEntityService
        self.roomEntityService = roomEntityService
    }
    
    func trySaveChanges() -> Future<Bool, Error>{
        if CoreDataManager.shared.managedContext.hasChanges {
            do {
                try CoreDataManager.shared.managedContext.save()
                return Future { promise in
                    promise(.success(true))
                }
            } catch {
                return Future { promise in
                    promise(.failure(error))
                }
            }
        } else {
            return Future { promise in
                promise(.success(false))
            }
        }
        
    }
    
}
