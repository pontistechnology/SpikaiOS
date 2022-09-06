//
//  UIImage+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.03.2022..
//

import Foundation
import UIKit

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
    
    static func safeImage(named name: String) -> UIImage {
        return UIImage(named: name) ?? missingImage
    }
    
    static let videoCall = safeImage(named: "videoCall")
    static let pencil = safeImage(named: "pencil")
    static let logo = safeImage(named: "logo")
    static let userImage = safeImage(named: "user_image")
    static let chatBubble = safeImage(named: "chatBubble")
    static let phoneCall = safeImage(named: "phoneCall")
    static let testImage = safeImage(named: "matejVida")
    static let rightArrow = safeImage(named: "rightArrow")
    static let downArrow = safeImage(named: "downArrow")
    static let deleteCell = safeImage(named: "deleteCell")
    static let error = safeImage(named: "error")
    static let sent = safeImage(named: "sent")
    static let plus = safeImage(named: "plus")
    static let send = safeImage(named: "send")
    static let smile = safeImage(named: "smile")
    static let close = safeImage(named: "close")
    static let camera = safeImage(named: "camera")
    static let microphone = safeImage(named: "microphone")
    static let files = safeImage(named: "files")
    
    static let library = safeImage(named: "library")
    static let location = safeImage(named: "location")
    static let contact = safeImage(named: "contact")
    static let house = safeImage(named: "house")
    static let docs = safeImage(named: "docs")
    static let search = safeImage(named: "search")
    static let delete = safeImage(named: "delete")
    static let play = safeImage(named: "play")
    static let delivered = safeImage(named: "delivered")
    static let seen = safeImage(named: "seen")
    static let fail = safeImage(named: "fail")
    static let waiting = safeImage(named: "waiting")
    static let pdfThumbnail = safeImage(named: "pdfThumbnail")
    static let unknownFileThumbnail = safeImage(named: "unknownFileThumbnail")
    
    
    
}
