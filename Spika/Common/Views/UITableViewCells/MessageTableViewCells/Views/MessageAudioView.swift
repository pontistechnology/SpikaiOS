//
//  MessageAudioView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageAudioView: UIView {
    let playButton = UIImageView(image: UIImage(safeImage: .play))
    private let durationLabel = CustomLabel(text: "02:23", textSize: 12, textColor: .logoBlue, fontName: .MontserratRegular)
    let slider = UISlider()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageAudioView: BaseView {
    func addSubviews() {
        addSubview(playButton)
        addSubview(durationLabel)
        addSubview(slider)
    }
    
    func styleSubviews() {
        slider.thumbTintColor = .logoBlue
        slider.minimumTrackTintColor = .logoBlue
        slider.setThumbImage(UIImage(safeImage: .thumb), for: .normal)
        slider.setThumbImage(UIImage(safeImage: .thumb), for: .highlighted)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = false
    }
    
    func positionSubviews() {
        playButton.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0), size: CGSize(width: 24, height: 24))

        slider.anchor(leading: playButton.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        slider.constrainWidth(138)
        slider.centerYToSuperview()
        
        durationLabel.anchor(leading: slider.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        durationLabel.centerYToSuperview()
    }
}

extension MessageAudioView {
    func reset() {
        slider.value = 0
        durationLabel.text = nil
        playButton.image = .init(safeImage: .play)
    }
    
    func setup(sliderValue: Float, duration: String? = nil) {
        slider.value = sliderValue
        guard let duration = duration else { return }
        durationLabel.text = duration
    }
}

//(duration/60 < 10 ? "0" : "") + "\(duration/60):" + (duration%60 < 10 ? "0" : "") + "\(duration%60)"
