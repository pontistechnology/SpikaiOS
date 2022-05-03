//
//  TestRepository.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine
import CoreData

class TestRepository: Repository {
   
    func saveRoom(room: Room) -> Future<Room, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    
    let networkService: NetworkService
    let databaseService: DatabaseService
    var subs = Set<AnyCancellable>()
    
    init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
    }
    
    func getMainContext() -> NSManagedObjectContext {
        databaseService.coreDataStack.mainMOC
    }
    
}
