//
//  UIImage+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.03.2022..
//

import Foundation
import UIKit

extension UIImage {
    static func imageFor(mimeType: String) -> UIImage {
        if mimeType.contains("application/pdf") {
            return UIImage(resource: .pdfFile)
        } else if mimeType.contains("application/vnd.openxmlformats-officedocument.wordprocessingml.document") {
            return UIImage(resource: .wordFile)
        } else if mimeType.contains("application/zip") {
            return UIImage(resource: .zipFile)
        } else {
            return UIImage(resource: .unknownFileThumbnail)
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
