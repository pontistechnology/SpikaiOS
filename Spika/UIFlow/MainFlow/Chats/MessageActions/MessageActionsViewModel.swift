//
//  MessageActionsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.01.2023..
//

import Foundation

enum MessageAction {
    case reaction(emoji: String)
    case reply
    case forward
    case copy
    case details
    case favorite
    case delete
}

class MessageActionsViewModel: BaseViewModel {
}
