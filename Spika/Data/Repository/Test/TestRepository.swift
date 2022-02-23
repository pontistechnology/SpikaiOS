//
//  TestRepository.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

class TestRepository: Repository {
    
    func uploadWholeFile(data: Data) -> CurrentValueSubject<Int, Never>{
        let ea = CurrentValueSubject<Int, Never>(334244)
        return ea
    }
    
    
    let networkService: NetworkService
    let databaseService: DatabaseService
    
    init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
    }
    
    func getPosts() -> AnyPublisher<[Post], Error> {
        return Fail<[Post], Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
