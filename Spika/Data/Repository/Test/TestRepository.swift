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
    

    func trySaveChanges() -> Future<Bool, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
    
    func saveRoom(room: Room) -> Future<RoomEntity, Error> {
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
    
    func getPosts() -> AnyPublisher<[Post], Error> {
        return Fail<[Post], Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getMainContext() -> NSManagedObjectContext {
        databaseService.coreDataStack.mainMOC
    }
    
}
