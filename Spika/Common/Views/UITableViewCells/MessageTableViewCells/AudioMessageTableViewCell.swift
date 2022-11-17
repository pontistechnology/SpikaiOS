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
    private let lineView = UIView(backgroundColor: .logoBlue)
    private let sliderView = UIView(backgroundColor: .logoBlue)
    private let durationLabel = CustomLabel(text: "02:23", textSize: 12, textColor: .logoBlue, fontName: .MontserratRegular)
    private var sliderLeadingConstraint = NSLayoutConstraint()
    private let timePublisher = PassthroughSubject<Double, Never>()
    
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
        
        sliderLeadingConstraint = sliderView.leadingAnchor.constraint(equalTo: lineView.leadingAnchor, constant: -9)
        sliderLeadingConstraint.isActive = true
        
        sliderView.constrainWidth(18)
        sliderView.constrainHeight(18)
        sliderView.centerYToSuperview()
        
        durationLabel.anchor(leading: lineView.trailingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        durationLabel.centerYToSuperview()
    }
}
// MARK: Public Functions

extension AudioMessageTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sliderLeadingConstraint.isActive = false
    }
    
    func updateCell(message: Message) {
        setupBindings()
    }
    
    func setAt(percent: Double) {
        let perPercent = 138.0 / 100
        sliderLeadingConstraint.constant = -9 + percent * perPercent * 100
    }
    
    func setupBindings() {
        playButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.tapPublisher.send(.playAudio(self.timePublisher))
        }.store(in: &subs)
        
        timePublisher.sink { [weak self] percent in
            self?.setAt(percent: percent)
        }.store(in: &subs)
    }
}

//(duration/60 < 10 ? "0" : "") + "\(duration/60):" + (duration%60 < 10 ? "0" : "") + "\(duration%60)"
