//
//  VideoPlayerViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.07.2024..
//

import AVKit
import AVFoundation
import Combine

class VideoPlayerViewModel: BaseViewModel {
    var asset: AVAsset!
    
    var avPlayer: AVPlayer {
        AVPlayer(playerItem: AVPlayerItem(asset: asset))
    }
}

class VideoPlayerViewController: AVPlayerViewController {
    var viewModel: VideoPlayerViewModel!
    private var subscriptions = Set<AnyCancellable>()
    let optionsLabel = RoundedLabel("Options", cornerRadius: 10)
    
    init(viewModel: VideoPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        player = viewModel.avPlayer
        try? AVAudioSession.sharedInstance()
            .setCategory(AVAudioSession.Category.playback,
                         mode: AVAudioSession.Mode.default,
                         options: [])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addShareButton()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addShareButton() {
        if let playerContentView = view.subviews.first {
            playerContentView.addSubview(optionsLabel)
            optionsLabel.centerXToSuperview()
            optionsLabel.centerYToSuperview()
            print("DEBUGPRINT: added label")
            optionsLabel.tap().sink { [weak self] _ in
                self?.player?.pause()
                print("DEBUGPRINT: tapped")
                self?.shareVideo()
            }.store(in: &subscriptions)
        } else {
            print("DEBUGPRINT: faila")
        }
    }
    
    func shareVideo() {
        
    }
}
