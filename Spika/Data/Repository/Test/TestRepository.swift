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
   
    let networkService: NetworkService
    let databaseService: DatabaseService
    var subs = Set<AnyCancellable>()
    
    let unreadRoomsPublisher = CurrentValueSubject<Int,Never>(0)
    
    init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
    }
    
    func getMainContext() -> NSManagedObjectContext {
        databaseService.coreDataStack.mainMOC
    }
    
}
