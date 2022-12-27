//
//  VideoMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.11.2022..
//

import UIKit

final class VideoMessageTableViewCell: BaseMessageTableViewCell {
    
    private let videoView = MessageVideoView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupVideoCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVideoCell() {
        containerStackView.addArrangedSubview(videoView)
    }
}

extension VideoMessageTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.reset()
    }
    
    func updateCell(message: Message) {
        // TODO: Change to duration later, for now is size
        let duration = "\((message.body?.file?.metaData?.duration ?? 0))" + " s"
        let thumbnailURL = message.body?.thumb?.id.fullFilePathFromId()
        videoView.setup(duration: duration, thumbnailURL: thumbnailURL)
        
        videoView.thumbnailImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.playVideo)
        }.store(in: &subs)
    }
}
