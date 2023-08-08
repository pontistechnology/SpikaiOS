//
//  UIImage+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.03.2022..
//

import Foundation
import UIKit

enum AssetName: String {
    case videoCall = "videoCall"
    case logo = "logo"
    case userImage = "userImage"
    case chatBubble = "chatBubble"
    case phoneCall = "phoneCall"
    case testImage = "matejVida"
    case rightArrow = "rightArrow"
    case downArrow = "downArrow"
    case deleteCell = "deleteCell"
    case error = "error"
    case sent = "sent"
    case plus = "plus"
    case send = "send"
    case smile = "smile"
    case close = "close"
    case camera = "camera"
    case microphone = "microphone"
    case files = "files"
    case library = "library"
    case location = "location"
    case contact = "contact"
    case closeActionsSheet = "closeActionsSheet"
    case house = "house"
    case docs = "docs"
    case search = "search"
    case delete = "delete"
    case play = "play"
    case delivered = "delivered"
    case seen = "seen"
    case fail = "fail"
    case waiting = "waiting"
    case cameraImage = "camera_image"
    case mutedIcon = "mutedIcon"
    case pinnedChatIcon = "pinnedChatIcon"
    case senderAction = "SenderAction"
    
    // File icons Ken
    case pdfThumbnail = "pdfThumbnail"
    case unknownFileThumbnail = "unknownFileThumbnail"
    case playVideo = "playVideo"
    
    // File icons design
    case pdfFile = "pdfFile"
    case wordFile = "wordFile"
    case zipFile = "zipFile"
    
    // Tabs
    case callHistoryTab = "callHistoryTab"
    case chatsTab = "chatsTab"
    case contactsTab = "contactsTab"
    case settingsTab = "settingsTab"
    
    case callHistoryTabFull = "callHistoryTabFull"
    case chatsTabFull = "chatsTabFull"
    case contactsTabFull = "contactsTabFull"
    case settingsTabFull = "settingsTabFull"
    
    case thumb = "thumb"
    
    // reply view icons
    case contactIcon = "contactIcon"
    case gifIcon = "gifIcon"
    case micIcon = "micIcon"
    case photoIcon = "photoIcon"
    case videoIcon = "videoIcon"
    
    // message actions icons
    case replyMessage = "replyMessage"
    case forwardMessage = "forwardMessage"
    case deleteMessage = "deleteMessage"
    case copyMessage = "copyMessage"
    case favoriteMessage = "favoriteMessage"
    case detailsMessage = "detailsMessage"
    case slideReply = "slideReply"
    case slideDelete = "slideDelete"
    case slideDetails = "slideDetails"
    case editIcon = "editIcon"
    case checkmark = "checkmark"
    case done = "done"
    case addCustomReaction = "addCustomReaction"
}

extension UIImage {    
    static var missingImage: UIImage {
        return UIImage(systemName: "externaldrive.badge.xmark")!
    }
    
    convenience init(safeImage: AssetName) {
        self.init(named: safeImage.rawValue)!
    }
}

extension UIImage {
    static func imageFor(mimeType: String) -> UIImage {
        if mimeType.contains("application/pdf") {
            return UIImage(safeImage: .pdfFile)
        } else if mimeType.contains("application/vnd.openxmlformats-officedocument.wordprocessingml.document") {
            return UIImage(safeImage: .wordFile)
        } else if mimeType.contains("application/zip") {
            return UIImage(safeImage: .zipFile)
        } else {
            return UIImage(safeImage: .unknownFileThumbnail)
        }
    }
}

extension UIImage {
    
    private var isSquare: Bool {
        return abs(self.size.width - self.size.height) < 20
    }
    
    func statusOfPhoto(for purpose: ImagePurpose) -> StateOfImage {
        // TODO: check is format wrong
        switch purpose {
        case .avatar:
            if !isSquare {
                return .wrongDimensions
            } else if self.size.width < 512 || self.size.height < 512 {
                return .badQuality
            }
        case .thumbnail:
            break
        case .fullSize:
            break
        }
        return .allOk
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(width: size.width * scaleFactor,
                                     height: size.height * scaleFactor)

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)

        let scaledImage = renderer.image { [weak self] _ in
            self?.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

enum ImagePurpose {
    case avatar
    case thumbnail
    case fullSize
}

enum StateOfImage {
    case badQuality
    case wrongDimensions
    case tooBig
    case wrongFormat
    case allOk
    
    var description: String {
        switch self {
        case .badQuality:
            return .getStringFor(.pleaseSelectLargerImage)
        case .wrongDimensions:
            return .getStringFor(.pleaseSelectSquare)
        case .tooBig:
            return .getStringFor(.selectedImageIsTooBig)
        case .wrongFormat:
            return .getStringFor(.unsupportedFormat)
        case .allOk:
            return .getStringFor(.allOk)
        }
    }
}
