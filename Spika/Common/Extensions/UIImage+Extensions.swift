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
    case pencil = "pencil"
    case logo = "logo"
    case userImage = "user_image"
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
    case mutedIcon = "muted_icon"
    
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
}

extension UIImage {
    func resizeImageToFitPixels(size: CGSize) -> UIImage? {
        let pixelsSize = CGSize(width: size.width / UIScreen.main.scale,
                                height: size.height / UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(pixelsSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: pixelsSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
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
