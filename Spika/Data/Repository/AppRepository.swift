//
//  AppRepository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

class AppRepository: Repository {
    
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func getPosts() -> AnyPublisher<[Post], Error> {
        let resources = Resources<[Post], EmptyRequestBody>(
            path: Constants.Endpoints.getPosts,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
}
