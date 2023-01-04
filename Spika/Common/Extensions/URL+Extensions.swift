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
        return thumbnail
    }
    
    func imageMetaData() -> MetaData {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?,
              let width = imageProperties[kCGImagePropertyPixelWidth] as? Int64,
              let height = imageProperties[kCGImagePropertyPixelHeight] as? Int64
        else {
            return MetaData(width: 0, height: 0, duration: 0)
        }
        return MetaData(width: width, height: height, duration: 0)
    }
    
    func videoThumbnail() -> UIImage {
        let asset = AVURLAsset(url: self)
        let imgGenerator = AVAssetImageGenerator(asset: asset) // TODO: will be deprecated ˇ
        guard let cgImage = try? imgGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
        else { return UIImage(systemName: "video")!}
        
        print("Video pokojo: ", asset.duration)
        
        
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

