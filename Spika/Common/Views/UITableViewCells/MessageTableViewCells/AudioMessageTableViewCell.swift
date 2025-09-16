//
//  AudioMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.11.2022..
//

import UIKit
import AVFoundation
import Combine

final class AudioMessageTableViewCell: BaseMessageTableViewCell2 {
    private let audioView = MessageAudioView()
    private let timePublisher = PassthroughSubject<Float, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAudioCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAudioCell() {
        hSTack.addArrangedSubview(audioView)
    }
}
// MARK: Public Functions

extension AudioMessageTableViewCell: BaseMessageTableViewCellProtocol {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        audioView.reset()
    }
    
    func updateCell(message: Message) {
        setupBindings()
    }
    
    func setAt(percent: Float) {
        audioView.setup(sliderValue: percent)
    }
    
    func setupBindings() {
        audioView.playButton.tap().sink { [weak self] _ in
            guard let self else { return }
            self.tapPublisher.send(.playAudio(playedPercentPublisher: self.timePublisher))
        }.store(in: &subs)
        
        timePublisher.sink { [weak self] percent in
            self?.setAt(percent: percent)
        }.store(in: &subs)
        
        audioView.slider.publisher(for: .valueChanged).sink { [weak self] valuee in
//            print("Value audio player: ", valuee)
        }.store(in: &subs)
    }
}
