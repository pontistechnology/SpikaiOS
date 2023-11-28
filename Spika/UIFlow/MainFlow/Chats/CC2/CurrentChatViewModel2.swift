//
//  CurrentChatViewModel2.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.11.2023..
//

import Foundation

class CurrentChatViewModel2: BaseViewModel, ObservableObject {
    @Published var room: Room
    @Published var scrollToMessageId: Int64?
    
    static let sortD = [
        NSSortDescriptor(key: "createdDate", ascending: true),
        NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
    
    init(repository: Repository, coordinator: Coordinator, room: Room, scrollToMessageId: Int64? = nil) {
        self.room = room
        self.scrollToMessageId = scrollToMessageId
        super.init(repository: repository, coordinator: coordinator)
    }
}
