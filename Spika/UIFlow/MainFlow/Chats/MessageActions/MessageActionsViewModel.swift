//
//  MessageActionsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

class MessageActionsViewModel: BaseViewModel {
    let reactions = ["👍", "❤️", "😂", "😲", "😥", "🙏"]
    let actions: [MessageAction] = [.reply, .forward, .copy, .details, .favorite, .delete]
}
