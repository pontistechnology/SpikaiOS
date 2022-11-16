//
//  AVURLAsset+Extension.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.08.2022..
//

import UIKit
import AVFoundation

extension AVURLAsset {
    convenience init(url: URL, mimeType: String) {
        self.init(url: url, options: ["AVURLAssetOutOfBandMIMETypeKey": mimeType])
    }
}
