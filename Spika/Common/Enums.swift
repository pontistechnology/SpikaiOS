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
    case save
    case delete
    
    var title: String {
        switch self {
        case .copy:
            return "Copied"
        case .forward:
            return "Forwarded"
        case .favorite:
            return "Added to favorite"
        case .save:
            return "Saved"
        case .delete:
            return "Deleted"
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
            return .primaryColor
        case .friend, .group:
            return .secondaryColor
        }
    }
}

enum ScrollToBottomType {
    case ifLastCellVisible
    case force(animated: Bool)
}

enum FRCChangeType {
    case insert(indexPath: IndexPath)
    case other
}

enum SSEEventType: String, Codable {
    case newMessage = "NEW_MESSAGE"
    case updateMessage = "UPDATE_MESSAGE"
    case deleteMessage = "DELETE_MESSAGE"
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
    case openFile
}

enum MessageAction {
    case reaction(emoji: String)
    case showCustomReactions
    case reply
    case forward
    case copy
    case details
    case favorite
    case delete
    case edit
    
    var textForLabel: String {
        switch self {
        case .reaction, .showCustomReactions:
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
        case .edit:
            return .getStringFor(.edit)
        }
    }
    
    var assetNameForIcon: AssetName {
        switch self {
        case .reaction, .showCustomReactions:
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
        case .edit:
            return .editIcon
        }
    }
}

enum EmojiSection: CaseIterable {
    case recent
    case smileysAndPeople
    case animalsAndNature
    case foodAndDrink
    case travelAndPlaces
    case activity
    case objects
    case symbols
    case flags
    
    var title: String {
        switch self {
        case .recent:
            return .getStringFor(.recent)
        case .smileysAndPeople:
            return .getStringFor(.smileysAndPeople)
        case .animalsAndNature:
            return .getStringFor(.animalsAndNature)
        case .foodAndDrink:
            return .getStringFor(.foodAndDrink)
        case .activity:
            return .getStringFor(.activity)
        case .travelAndPlaces:
            return .getStringFor(.travelAndPlaces)
        case .objects:
            return .getStringFor(.objects)
        case .symbols:
            return .getStringFor(.symbols)
        case .flags:
            return .getStringFor(.flags)
        }
    }
    
    var icon: UIImage {
        switch self {
        case .recent:
            return UIImage(safeImage: .emojiSectionClock)
        case .smileysAndPeople:
            return UIImage(safeImage: .emojiSectionSmiley)
        case .animalsAndNature:
            return UIImage(safeImage: .emojiSectionPaw)
        case .foodAndDrink:
            return UIImage(safeImage: .emojiSectionBurger)
        case .activity:
            return UIImage(safeImage: .emojiSectionBall)
        case .travelAndPlaces:
            return UIImage(safeImage: .emojiSectionCar)
        case .objects:
            return UIImage(safeImage: .emojiSectionLightbulb)
        case .symbols:
            return UIImage(safeImage: .emojiSectionHeart)
        case .flags:
            return UIImage(safeImage: .emojiSectionFlag)
        }
    }
}


enum SpikaTheme: String, CaseIterable {
    
    case darkMarine, neon
    
    // TODO: - localize?
    var title: String {
        switch self {
        case .neon:
            return "Neon"
        case .darkMarine:
            return "Dark Marine"
        }
    }
    
    // first one should be rounded on top corners, last one on bottom, middle ones without rounding
    var corners: UIRectCorner? {
        self == SpikaTheme.allCases.first ? .topCorners : (self == SpikaTheme.allCases.last ? UIRectCorner.bottomCorners : nil)
    }
        
    
    struct SpikaColors {
        let _backgroundGradientColors: [ColorResource] // gradient in order
        let _primaryColor: ColorResource
        let _secondaryColor: ColorResource
        let _tertiaryColor: ColorResource
        let _textPrimary: ColorResource
        let _textSecondary: ColorResource
        let _additionalColor: ColorResource
        let _secondAdditionalColor: ColorResource
        let _thirdAdditionalColor: ColorResource
        let _fourthAdditionalColor: ColorResource
        let _warningColor: ColorResource
        let _secondWarningColor: ColorResource
    }
    
    
    func colors() -> SpikaColors {
        return switch self {
        case .darkMarine:
            SpikaColors(_backgroundGradientColors: [.DarkMarine.BackgroundGradient.gradient1,
                                                    .DarkMarine.BackgroundGradient.gradient2],
                        _primaryColor: .DarkMarine.primary,
                        _secondaryColor: .DarkMarine.secondary,
                        _tertiaryColor: .DarkMarine.tertiary,
                        _textPrimary: .DarkMarine.textPrimary,
                        _textSecondary: .DarkMarine.textSecondary,
                        _additionalColor: .DarkMarine.additional1,
                        _secondAdditionalColor: .DarkMarine.additional2,
                        _thirdAdditionalColor: .DarkMarine.additional3,
                        _fourthAdditionalColor: .DarkMarine.additional4,
                        _warningColor: .DarkMarine.warning1,
                        _secondWarningColor: .DarkMarine.warning2)
        case .neon:
            SpikaColors(_backgroundGradientColors: [.Neon.BackgroundGradient.gradient1,
                                                    .Neon.BackgroundGradient.gradient2,
                                                    .Neon.BackgroundGradient.gradient3,
                                                    .Neon.BackgroundGradient.gradient4],
                        _primaryColor: .Neon.primary,
                        _secondaryColor: .Neon.secondary,
                        _tertiaryColor: .Neon.tertiary,
                        _textPrimary: .Neon.textPrimary,
                        _textSecondary: .Neon.textSecondary,
                        _additionalColor: .Neon.additional1,
                        _secondAdditionalColor: .Neon.additional2,
                        _thirdAdditionalColor: .Neon.additional3,
                        _fourthAdditionalColor: .Neon.additional4,
                        _warningColor: .Neon.warning1,
                        _secondWarningColor: .Neon.warning2)
        }
    }
}




