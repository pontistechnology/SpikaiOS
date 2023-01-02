//
//  URL+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.08.2022..
//

import UIKit
import AVFoundation

extension URL {
    func imageThumbnail() -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?,
              let thumbnail = downsample(imageSource: imageSource)
        else {
            return UIImage(systemName: "photo")!
        }
        
        
        print("POKOJO: w ", imageProperties[kCGImagePropertyPixelWidth])
        print("POKOJO: s ", imageProperties)
        print("POKOJO: h ", imageProperties[kCGImagePropertyPixelHeight])
        return thumbnail
    }
    
    func videoThumbnail() -> UIImage {
        let asset = AVURLAsset(url: self)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        guard let cgImage = try? imgGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
        else { return UIImage(systemName: "video")!}
        
        return UIImage(cgImage: cgImage)
    }
    
    func downsample(imageSource: CGImageSource,
                    to pointSize: CGSize = CGSize(width: 72, height: 72),
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    func copyFileFromURL(to targetURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try FileManager.default.copyItem(at: self, to: targetURL)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

