//
//  AppRepository+Chat.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import Combine

extension AppRepository {
    
    // MARK: UserDefaults
    
    
    // MARK: Network
    
    
    // MARK: Database
    
    func createChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        return databaseService.chatEntityService.saveChat(chat)
    }
    
    func getChats() -> Future<[LocalChat], Error> {
        return databaseService.chatEntityService.getChats()
    }
    
    func updateChat(_ chat: LocalChat) -> Future<LocalChat, Error> {
        return databaseService.chatEntityService.updateChat(chat)
    }
    
    func addUserToChat(chat: LocalChat, user: LocalUser) -> Future<LocalChat, Error> {
        return databaseService.chatEntityService.addUserToChat(chat: chat, user: user)
    }
    
    func getUsersForChat(chat: LocalChat) -> Future<[LocalUser], Error> {
        return databaseService.chatEntityService.getUsersForChat(chat: chat)
    }
}
