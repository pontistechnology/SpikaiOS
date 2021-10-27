//
//  AppRepository+Messages.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import Foundation
import Combine

extension AppRepository {
    func saveMessage(_ message: Message) -> Future<Message, Error> {
        return databaseService.messageEntityService.saveMessage(message)
    }
    
    func getMessagesForChat(chat: Chat) -> Future<[Message], Error> {
        return databaseService.messageEntityService.getMessagesForChat(chat: chat)
    }
}
