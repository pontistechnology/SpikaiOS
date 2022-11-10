//
//  ChatDetailsViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import Combine

class ChatDetailsViewModel: BaseViewModel {
 
    let chat: Room
    
    init(repository: Repository, coordinator: Coordinator, chat: Room) {
        self.chat = chat
        super.init(repository: repository, coordinator: coordinator)
    }
    
}
