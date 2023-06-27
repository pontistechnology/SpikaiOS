//
//  AVAsset.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.06.2023..
//

import AVFoundation

extension AVAsset {
    func videoMetadata() async -> MetaData? {
        guard let duration = try? await self.load(.duration),
              let dimensions = try? await self.load(.tracks).first?.load(.naturalSize)
        else { return nil }
        return MetaData(width: dimensions.width.roundedInt64,
                        height: dimensions.height.roundedInt64,
                        duration: duration.seconds.roundedInt64)
    }
}
