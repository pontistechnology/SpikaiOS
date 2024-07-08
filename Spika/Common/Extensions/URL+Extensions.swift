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
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        guard let cgImage = try? imgGenerator.copyCGImage(at: CMTime(seconds: 0.1, preferredTimescale: 1), actualTime: nil)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
            .scalePreservingAspectRatio(targetSize: CGSizeMake(85, 85)) // 256px, scale factor is 3
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

// MARK: - video exporting

extension URL {
    func compressAsMP4(name: String) async -> URL? {
        let allowedExtensions = ["mov", "mp4"]
        guard allowedExtensions.contains(self.pathExtension),
              let exportSession = AVAssetExportSession(asset: AVAsset(url: self),
                                            presetName: AVAssetExportPreset960x540),
              let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first
        else { return nil }
        
        // TODO: - move to constants
        let newFileUrl = documentsDirectory.appendingPathComponent("\(name).mp4")
        if FileManager.default.fileExists(atPath: newFileUrl.path) {
            try? FileManager.default.removeItem(at: newFileUrl)
            // TODO: - add error handling
        }
        
        exportSession.outputURL = newFileUrl
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // TODO: - uncomment later for trim
//        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
//        let range = CMTimeRangeMake(start: start, duration: duration)
//        exportSession.timeRange = range
        
        await exportSession.export()
        
        // after export, delete old file
        try? FileManager.default.removeItem(at: self)
        
        switch exportSession.status {
        case .unknown:
            print("unknown")
        case .waiting:
            print("waiting")
        case .exporting:
            print("exporting")
        case .completed:
            return newFileUrl
        case .failed:
            print("evo errora: ", exportSession.error)
            print("failed")
        case .cancelled:
            print("cancelled")
            // TODO: - handle cancell
        @unknown default:
            print("unknown new cases")
        }
        
        return nil
    }
}
