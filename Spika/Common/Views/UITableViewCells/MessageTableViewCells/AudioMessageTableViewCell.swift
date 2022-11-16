//
//  AudioMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.11.2022..
//

import UIKit
import AVFoundation
import Combine

final class AudioMessageTableViewCell: BaseMessageTableViewCell {
    
    var audioPlayer: AVPlayer?
    private let voiceView = VoiceMessageView(duration: 55)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAudioCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAudioCell() {
        containerView.addSubview(voiceView)
        voiceView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
// MARK: Public Functions

extension AudioMessageTableViewCell {
    
    func updateCell(message: Message) {
        let link = URL(string: "https://clover.spika.chat/api/upload/files/2110.mp3")!
        audioPlayer = AVPlayer(url: link)
        setupBindings()
    }
    
    func setupBindings() {
        voiceView.playButton.tap().sink { [weak self] _ in
            self?.audioPlayer?.play()
        }.store(in: &subs)
    }
}

