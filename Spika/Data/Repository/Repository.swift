//
//  Repository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

protocol Repository {
    // this is test endpoint, needs to be deleted in future
    func getPosts() -> AnyPublisher<[Post], Error>
}
