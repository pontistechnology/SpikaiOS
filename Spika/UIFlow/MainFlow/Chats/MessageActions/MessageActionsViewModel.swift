//
//  MessageActionsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

class MessageActionsViewModel: BaseViewModel {
    private let isMyMessage: Bool
    let reactions = ["👍", "❤️", "😂", "😲", "😥", "🙏"]
    let actions: [MessageAction]
    
    init(repository: Repository, coordinator: Coordinator, isMyMessage: Bool) {
        self.isMyMessage = isMyMessage
        self.actions = isMyMessage
        ? [.reply, .forward, .copy, .edit, .details, .favorite, .delete]
        : [.reply, .forward, .copy, .details, .favorite, .delete]
        super.init(repository: repository, coordinator: coordinator)
    }
}
