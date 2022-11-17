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
    private let publisher = PassthroughSubject<Double, Never>()
    
    deinit {
        removeObserver()
    }
    
    func removeObserver() {
        guard let timeObserverToken = timeObserverToken else { return }
        audioPlayer?.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }
    
    func playAudio(path: String, mimeType: String) -> PassthroughSubject<Double, Never>? {
        removeObserver()
        guard let url = URL(string: path) else { return nil}
        let asset = AVURLAsset(url: url, mimeType: mimeType)
        audioPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        audioPlayer?.play()
        addObserver()
        return publisher
    }
    
    func addObserver() {
        removeObserver()
        timeObserverToken = audioPlayer?
            .addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4),
                                     queue: nil, using: { [weak self] time in
                guard let self = self,
                      let duration = self.audioPlayer?.currentItem?.duration.seconds,
                      duration > 0
                else { return }
                self.publisher.send(time.seconds / duration)
            })
    }
}
