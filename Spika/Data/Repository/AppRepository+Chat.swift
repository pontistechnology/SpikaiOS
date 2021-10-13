//
//  AppRepository+Chat.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import Combine

extension AppRepository {
    func createChat(_ chat: Chat) -> Future<Chat, Error> {
        return databaseService.chatEntityService.saveChat(chat)
    }
    
    func getChats() -> Future<[Chat], Error> {
        return databaseService.chatEntityService.getChats()
    }
    
    func updateChat(_ chat: Chat) -> Future<Chat, Error> {
        return databaseService.chatEntityService.updateChat(chat)
    }
}
