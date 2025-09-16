//
//  MessageActionsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

class MessageActionsViewModel: BaseViewModel {
    let reactions = ["👍", "❤️", "😂", "😲", "😥", "🙏"]
    let actions: [MessageAction]
    
    init(repository: Repository, coordinator: Coordinator, actions: [MessageAction]) {
        self.actions = actions
        super.init(repository: repository, coordinator: coordinator)
    }
}
