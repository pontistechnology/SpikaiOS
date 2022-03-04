//
//  VoiceMessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.03.2022..
//

import Foundation
import UIKit

class VoiceMessageView: UIView, BaseView {
    
    static let voiceMessageHeight = 50.0
    static let voiceMessageWidth  = 240.0
    
    let playButton = UIButton()
    let lineView = UIView()
    let markerView = UIView()
    let durationLabel = CustomLabel(text: "00:00", textSize: 12, textColor: .logoBlue, fontName: .MontserratBold)
    let duration: Int
    
    init(duration: Int) {
        self.duration = duration
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(playButton)
        addSubview(lineView)
        addSubview(durationLabel)
        addSubview(markerView)
    }
    
    func styleSubviews() {
        backgroundColor = .chatBackground
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        playButton.setImage(UIImage(named: "play"), for: .normal)
        lineView.backgroundColor = .logoBlue
        markerView.backgroundColor = .logoBlue
        markerView.layer.cornerRadius = 9
        markerView.layer.masksToBounds = true
        durationLabel.text = (duration/60 < 10 ? "0" : "") + "\(duration/60):" + (duration%60 < 10 ? "0" : "") + "\(duration%60)"
    }
    
    func positionSubviews() {
        
        playButton.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 0), size: CGSize(width: 24, height: 24))
        playButton.centerYToSuperview()
        
        lineView.anchor(leading: playButton.trailingAnchor, trailing: durationLabel.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 10))
        lineView.constrainHeight(2)
        lineView.centerYToSuperview()
        
        markerView.anchor(leading: lineView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 18, height: 18))
        markerView.centerYToSuperview()
        
        durationLabel.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        durationLabel.centerYToSuperview()
    }
}
