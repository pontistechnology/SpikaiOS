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
    
    var replyBackgroundColor: UIColor {
        switch self {
        case .me:
            return .secondaryColor
        case .friend, .group:
            return .primaryColor
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
    case deleteMessageRecord = "DELETE_MESSAGE_RECORD"
    case newRoom = "NEW_ROOM"
    case updateRoom = "UPDATE_ROOM"
    case deleteRoom = "DELETE_ROOM"
    case userUpdate = "USER_UPDATE"
    case seenRoom = "SEEN_ROOM"
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
    case download
    
    var textForLabel: String {
        return switch self {
        case .reaction, .showCustomReactions:
            ""
        case .reply:
            .getStringFor(.reply)
        case .forward:
            .getStringFor(.forward)
        case .copy:
            .getStringFor(.copy)
        case .details:
            .getStringFor(.details)
        case .favorite:
            .getStringFor(.favorite)
        case .delete:
            .getStringFor(.delete)
        case .edit:
            .getStringFor(.edit)
        case .download:
            .getStringFor(.download)        }
    }
    
    var assetNameForIcon: ImageResource {
        return switch self {
        case .reaction, .showCustomReactions:
            .unknownFileThumbnail
        case .reply:
            .replyMessage
        case .forward:
            .forwardMessage
        case .copy:
            .copyMessage
        case .details:
            .detailsMessage
        case .favorite:
            .favoriteMessage
        case .delete:
            .deleteMessage
        case .edit:
            .editIcon
        case .download:
            .downloadMessage
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
            return UIImage(resource: .emojiSectionClock)
        case .smileysAndPeople:
            return UIImage(resource: .emojiSectionSmiley)
        case .animalsAndNature:
            return UIImage(resource: .emojiSectionPaw)
        case .foodAndDrink:
            return UIImage(resource: .emojiSectionBurger)
        case .activity:
            return UIImage(resource: .emojiSectionBall)
        case .travelAndPlaces:
            return UIImage(resource: .emojiSectionCar)
        case .objects:
            return UIImage(resource: .emojiSectionLightbulb)
        case .symbols:
            return UIImage(resource: .emojiSectionHeart)
        case .flags:
            return UIImage(resource: .emojiSectionFlag)
        }
    }
}


enum SpikaTheme: String, CaseIterable {
    
    case darkMarine, neon, lightMarine, lightGreen
    
    // TODO: - localize?
    var title: String {
        return switch self {
        case .neon: "Neon"
        case .darkMarine: "Dark Marine"
        case .lightMarine: "Light Marine"
        case .lightGreen: "Light Green"
        }
    }
    
    // first one should be rounded on top corners, others without rounding
    var corners: UIRectCorner? {
        self == SpikaTheme.allCases.first ? .topCorners : nil
    }
        
    
    struct SpikaColors {
        let _backgroundGradientColors: [ColorResource] // gradient in order
        let _primaryColor: ColorResource
        let _secondaryColor: ColorResource
        let _tertiaryColor: ColorResource
        let _textPrimary: ColorResource
        let _textSecondary: ColorResource
        let _textTertiary: ColorResource
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
                        _textTertiary: .DarkMarine.textTertiary,
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
                        _textTertiary: .Neon.textTertiary,
                        _additionalColor: .Neon.additional1,
                        _secondAdditionalColor: .Neon.additional2,
                        _thirdAdditionalColor: .Neon.additional3,
                        _fourthAdditionalColor: .Neon.additional4,
                        _warningColor: .Neon.warning1,
                        _secondWarningColor: .Neon.warning2)
        case .lightMarine:
            SpikaColors(_backgroundGradientColors: [.LightMarine.BackgroundGradient.gradient1,
                                                    .LightMarine.BackgroundGradient.gradient2],
                        _primaryColor: .LightMarine.primary,
                        _secondaryColor: .LightMarine.secondary,
                        _tertiaryColor: .LightMarine.tertiary,
                        _textPrimary: .LightMarine.textPrimary,
                        _textSecondary: .LightMarine.textSecondary, 
                        _textTertiary: .LightMarine.textTertiary,
                        _additionalColor: .LightMarine.additional1,
                        _secondAdditionalColor: .LightMarine.additional2,
                        _thirdAdditionalColor: .LightMarine.additional3,
                        _fourthAdditionalColor: .LightMarine.additional4,
                        _warningColor: .LightMarine.warning1,
                        _secondWarningColor: .LightMarine.warning2)
        case .lightGreen:
            SpikaColors(_backgroundGradientColors: [.LightGreen.BackgroundGradient.gradient1,
                                                    .LightGreen.BackgroundGradient.gradient2],
                        _primaryColor: .LightGreen.primary,
                        _secondaryColor: .LightGreen.secondary,
                        _tertiaryColor: .LightGreen.tertiary,
                        _textPrimary: .LightGreen.textPrimary,
                        _textSecondary: .LightGreen.textSecondary, 
                        _textTertiary: .LightGreen.textTertiary,
                        _additionalColor: .LightGreen.additional1,
                        _secondAdditionalColor: .LightGreen.additional2,
                        _thirdAdditionalColor: .LightGreen.additional3,
                        _fourthAdditionalColor: .LightGreen.additional4,
                        _warningColor: .LightGreen.warning1,
                        _secondWarningColor: .LightGreen.warning2)
        }
    }
}

enum SelectedUserOrGroup: Identifiable, Hashable {
    case user(UserEntity)
    case room(RoomEntity)
    
    var id: String {
        return switch self {
        case .user(let userEntity):
            "user\(userEntity.id)" //prefix is needed because room and user can have same number for id
        case .room(let roomEntity):
            "room\(roomEntity.id)"
        }
    }
    
    var user: UserEntity? {
        switch self {
        case .user(let userEntity):
            userEntity
        case .room:
            nil
        }
    }
    
    var room: RoomEntity? {
        switch self {
        case .user:
            nil
        case .room(let roomEntity):
            roomEntity
        }
    }
    
    var avatarURL: URL? {
        switch self {
        case .user(let userEntity):
            userEntity.avatarFileId.fullFilePathFromId()
        case .room(let roomEntity):
            roomEntity.avatarFileId.fullFilePathFromId()
        }
    }
    
    var displayName: String {
        switch self {
        case .user(let userEntity):
            User(entity: userEntity).getDisplayName()
        case .room(let roomEntity):
            roomEntity.name ?? "no name"
        }
    }
    
    var description: String? {
        switch self {
        case .user(let userEntity):
            user?.telephoneNumber
        case .room(let roomEntity):
            room?.type
        }
    }
    
    var placeholderImage: ImageResource {
        switch self {
        case .user:
            .rDdefaultUser
        case .room:
            .rdDefaultGroup
        }
    }
}

extension [SelectedUserOrGroup] {
    var onlyUsers: [User] {self.compactMap { $0.user }.compactMap { User(entity: $0)}}
    
    var onlyUserIds: [Int64] {
        onlyUsers.compactMap { $0.id }
    }
    
    var onlyRoomIds: [Int64] {self.compactMap { $0.room?.id }}
}



