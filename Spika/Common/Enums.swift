//
//  Enums+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit
import Combine

enum OneSecPopUpType {
    case copy
    case forward
    case favorite
    
    var title: String {
        switch self {
        case .copy:
            return "Copied"
        case .forward:
            return "Forwarded"
        case .favorite:
            return "Added to favorite"
        }
    }
}

enum PopUpType {
    case errorMessage(_ message: String)
    
    var isBlockingUI: Bool {
        switch self {
        case .errorMessage:
            return false
        }
    }
    
    func frame(for scene: UIWindowScene) -> CGRect {
        isBlockingUI
        ? CGRect(x: 0, y: 0, width: scene.screen.bounds.width, height: scene.screen.bounds.height)
        : CGRect(x: 0, y: 0, width: scene.screen.bounds.width, height: 150)
    }
}

enum AlertViewButton {
    case regular(title: String)
    case destructive(title: String)
    
    var color: UIColor {
        switch self {
        case .regular:
            return .primaryColor
        case .destructive:
            return .appRed
        }
    }
    
    var title: String {
        switch self {
        case .regular(let title):
            return title
        case .destructive(let title):
            return title
        }
    }
    
    var style: UIAlertAction.Style {
        switch self {
        case .regular:
            return .default
        case .destructive:
            return .destructive
        }
    }
}

enum MessageSender {
    case me
    case friend
    case group
    
    var reuseIdentifierPrefix: String {
        switch self {
        case .me:
            return "My"
        case .friend:
            return "Friend"
        case .group:
            return "Group"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .me:
            return .myChatBackground
        case .friend, .group:
            return .chatBackground
        }
    }
}

enum ScrollToBottomType {
    case ifLastCellVisible
    case force
}

enum FRCChangeType {
    case insert(indexPath: IndexPath)
    case other
}

enum SSEEventType: String, Codable {
    case newMessage = "NEW_MESSAGE"
    case newMessageRecord = "NEW_MESSAGE_RECORD"
    case deletedMessageRecord = "DELETED_MESSAGE_RECORD"
    case newRoom = "NEW_ROOM"
    case updateRoom = "UPDATE_ROOM"
    case deleteRoom = "DELETE_ROOM"
    case userUpdate = "USER_UPDATE"
    case seenRoom = "SEEN_ROOM"
}

enum CustomFontName: String {
    case MontserratRegular = "Montserrat-Regular"
    case MontserratBold = "Montserrat-Bold"
    case MontserratBlack = "Montserrat-Black"
    case MontserratExtraBold = "Montserrat-ExtraBold"
    case MontserratExtraLight = "Montserrat-ExtraLight"
    case MontserratLight = "Montserrat-Light"
    case MontserratMedium = "Montserrat-Medium"
    case MontserratSemiBold = "Montserrat-SemiBold"
    case MontserratThin = "Montserrat-Thin"
}

enum MessageCellTaps {
    case playVideo
    case playAudio(playedPercentPublisher: PassthroughSubject<Float, Never>)
    case openImage
    case scrollToReply
    case showReactions
}

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
