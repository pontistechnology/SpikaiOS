//
//  TestRepository+Chat.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

extension TestRepository {
    func createChat(_ chat: Chat) -> Future<Chat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getChats() -> Future<[Chat], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func updateChat(_ chat: Chat) -> Future<Chat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
}
