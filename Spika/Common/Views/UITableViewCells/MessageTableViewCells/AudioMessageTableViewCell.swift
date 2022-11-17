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
    private let playButton = UIImageView(image: UIImage(safeImage: .play))
    private let lineView = UIView(backgroundColor: .logoBlue)
    private let sliderView = UIView(backgroundColor: .logoBlue)
    private let durationLabel = CustomLabel(text: "00:23", textSize: 12, textColor: .logoBlue, fontName: .MontserratRegular)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAudioCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAudioCell() {
        containerView.addSubview(playButton)
        containerView.addSubview(lineView)
        lineView.addSubview(sliderView)
        containerView.addSubview(sliderView)
        containerView.addSubview(durationLabel)
        
        sliderView.layer.cornerRadius = 9
        sliderView.layer.masksToBounds = true
        
        playButton.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0), size: CGSize(width: 24, height: 24))
        
        lineView.anchor(leading: playButton.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10))
        lineView.constrainHeight(2)
        lineView.constrainWidth(138)
        lineView.centerYToSuperview()
        
        sliderView.anchor(leading: lineView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: -9, bottom: 0, right: 0), size: CGSize(width: 18, height: 18))
        sliderView.centerYToSuperview()
        
        durationLabel.anchor(leading: lineView.trailingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        durationLabel.centerYToSuperview()
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
        playButton.tap().sink { [weak self] _ in
            self?.audioPlayer?.play()
        }.store(in: &subs)
    }
}

//(duration/60 < 10 ? "0" : "") + "\(duration/60):" + (duration%60 < 10 ? "0" : "") + "\(duration%60)"
