//
//  UTType+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.08.2022..
//

import UniformTypeIdentifiers
import UIKit

extension UTType {
    func thumbnail() -> UIImage {
        switch self {
        case .pdf:
            return UIImage(safeImage: .pdfThumbnail)
        default:
            return UIImage(safeImage: .unknownFileThumbnail)
        }
    }
}
