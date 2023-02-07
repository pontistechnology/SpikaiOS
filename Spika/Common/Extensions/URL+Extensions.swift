//
//  URL+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.08.2022..
//

import UIKit
import AVFoundation

extension URL {
    func imageMetaData() -> MetaData? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?,
              let width = imageProperties[kCGImagePropertyPixelWidth] as? Int64,
              let height = imageProperties[kCGImagePropertyPixelHeight] as? Int64
        else {
            return nil
        }
        return MetaData(width: width, height: height, duration: 0)
    }
    
    func videoThumbnail() -> UIImage? {
        let asset = AVURLAsset(url: self)
        let imgGenerator = AVAssetImageGenerator(asset: asset) // TODO: will be deprecated ˇ
        guard let cgImage = try? imgGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
        else { return nil}
        return UIImage(cgImage: cgImage)
    }
    
    func videoMetaData() -> MetaData? {
//        let asset = AVURLAsset(url: self)
//        // A CMTime value.
//        let duration = try? await asset.load(.duration)
//        // An array of AVMetadataItem for the asset.
//        let metadata = try? await asset.load(.metadata)
//        let imgGenerator = AVAssetImageGenerator(asset: asset) // TODO: will be deprecated
//        guard let cgImage = try? imgGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
//        else { return nil}
        
        return MetaData(width: 100, height: 100, duration: 1)
    }
    
    func downsample(isForThumbnail: Bool = false) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, imageSourceOptions),
              let imageMetadata = self.imageMetaData()
        else {
            return nil
        }
        let maxPixels = isForThumbnail ? 256 : maxDimensionInPixels(width: imageMetadata.width,
                                                                    height: imageMetadata.height)

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        else {
            return nil
        }
        return UIImage(cgImage: downsampledImage)
    }
    
    private func maxDimensionInPixels(width: Int64, height: Int64) -> Int64 {
        let min = min(width, height)
        let max = max(width, height)
        return min < 1080 ? max : (1080 * max / min)
    }
}
