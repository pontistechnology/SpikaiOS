//
//  AudioPlayer.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation
import AVFoundation
import Combine

class AudioPlayer {
    private var audioPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private let publisher = PassthroughSubject<Float, Never>()
    
    deinit {
        removeObserver()
    }
    
    func playAudio(url: URL, mimeType: String) -> PassthroughSubject<Float, Never>? {
        removeObserver()
        let asset = AVURLAsset(url: url, mimeType: mimeType)
        audioPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        audioPlayer?.play()
        addObserver()
        return publisher
    }
    
    private func addObserver() {
        removeObserver()
        timeObserverToken = audioPlayer?
            .addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4),
                                     queue: nil, using: { [weak self] time in
                guard let self,
                      let duration = self.audioPlayer?.currentItem?.duration.seconds,
                      duration > 0
                else { return }
                self.publisher.send(Float(time.seconds / duration))
            })
    }
    
    private func removeObserver() {
        guard let timeObserverToken = timeObserverToken else { return }
        audioPlayer?.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }
}
