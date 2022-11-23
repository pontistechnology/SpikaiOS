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
    
    private let playButton = UIImageView(image: UIImage(safeImage: .play))
    private let durationLabel = CustomLabel(text: "02:23", textSize: 12, textColor: .logoBlue, fontName: .MontserratRegular)
    private let slider = UISlider()
    
    private let timePublisher = PassthroughSubject<Float, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAudioCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAudioCell() {
        containerView.addSubview(playButton)
        containerView.addSubview(durationLabel)
        containerView.addSubview(slider)
        
        slider.thumbTintColor = .logoBlue
        slider.minimumTrackTintColor = .logoBlue
        slider.setThumbImage(UIImage(safeImage: .thumb), for: .normal)
        slider.setThumbImage(UIImage(safeImage: .thumb), for: .highlighted)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = false
        
        playButton.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0), size: CGSize(width: 24, height: 24))

        slider.anchor(leading: playButton.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        slider.constrainWidth(138)
        slider.centerYToSuperview()
        
        durationLabel.anchor(leading: slider.trailingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        durationLabel.centerYToSuperview()
    }
}
// MARK: Public Functions

extension AudioMessageTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        slider.value = 0
    }
    
    func updateCell(message: Message) {
        setupBindings()
    }
    
    func setAt(percent: Float) {
        slider.value = percent
    }
    
    func setupBindings() {
        playButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.tapPublisher.send(.playAudio(playedPercentPublisher: self.timePublisher))
        }.store(in: &subs)
        
        timePublisher.sink { [weak self] percent in
            self?.setAt(percent: percent)
        }.store(in: &subs)
        
        slider.publisher(for: .valueChanged).sink { [weak self] _ in
            print("Value: ", self?.slider.value)
        }.store(in: &subs)
    }
}

//(duration/60 < 10 ? "0" : "") + "\(duration/60):" + (duration%60 < 10 ? "0" : "") + "\(duration%60)"
