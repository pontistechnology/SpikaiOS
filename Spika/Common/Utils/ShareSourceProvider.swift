//
//  ShareSourceProvider.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.07.2024..
//

import LinkPresentation
import UIKit


enum ShareActivityType {
    case sharePdf(temporaryURL: URL, file: FileData)
    case sharePhoto(url: URL)
    
//    case shareFile
//    case shareVideo
    
    var fileName: String {
        switch self {
        case .sharePdf(_, let file):
            file.fileName?.ensureExtension() ?? "unkown.pdf"
        case .sharePhoto:
            "not used"
        }
    }
}

extension String {
    // TODO: - add enum with extensions
    func ensureExtension() -> String {
        self.lowercased().hasSuffix(".pdf") ? self : self.appending(".pdf")
    }
}

class ShareSourceProvider: NSObject, UIActivityItemSource {
    let shareType: ShareActivityType
    
    init(shareType: ShareActivityType) {
        self.shareType = shareType
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        switch shareType {
        case .sharePdf(let temporaryURL, _):
            return temporaryURL
        case .sharePhoto(let image):
            return image        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch shareType {
        case .sharePdf(let temporaryURL, _):
            return temporaryURL
        case .sharePhoto(let image):
            return image
        }
    }
}

