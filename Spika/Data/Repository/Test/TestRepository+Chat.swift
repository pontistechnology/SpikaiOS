//
//  TestRepository+Chat.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

extension TestRepository {
    func createChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getChats() -> Future<[LocalChat], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func updateChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
}
