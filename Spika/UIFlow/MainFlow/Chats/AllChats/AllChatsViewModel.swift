//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation

class AllChatsViewModel: BaseViewModel {
    
    func presentNewChatScreen() {
        getAppCoordinator()?.presentNewChatScreen()
    }
    
    func presentCurrentChatScreen() {
        getAppCoordinator()?.presentCurrentChatScreen()
    }
}
