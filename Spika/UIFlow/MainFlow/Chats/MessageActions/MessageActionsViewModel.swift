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
    
    var textForLabel: String {
        switch self {
        case .reaction(_):
            return ""
        case .reply:
            return .getStringFor(.reply)
        case .forward:
            return .getStringFor(.forward)
        case .copy:
            return .getStringFor(.copy)
        case .details:
            return .getStringFor(.details)
        case .favorite:
            return .getStringFor(.favorite)
        case .delete:
            return .getStringFor(.delete)
        }
    }
    
    var assetNameForIcon: AssetName {
        switch self {
        case .reaction(_):
            return .unknownFileThumbnail
        case .reply:
            return .replyMessage
        case .forward:
            return .forwardMessage
        case .copy:
            return .copyMessage
        case .details:
            return .detailsMessage
        case .favorite:
            return .favoriteMessage
        case .delete:
            return .deleteMessage
        }
    }
}

class MessageActionsViewModel: BaseViewModel {
}
