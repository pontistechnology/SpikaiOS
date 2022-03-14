//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation

class AllChatsViewModel: BaseViewModel {
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen() {
//        getAppCoordinator()?.presentCurrentChatScreen()
    }
}
