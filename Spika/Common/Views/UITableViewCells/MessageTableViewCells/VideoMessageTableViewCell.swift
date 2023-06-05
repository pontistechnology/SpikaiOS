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

extension VideoMessageTableViewCell: BaseMessageTableViewCellProtocol {
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.reset()
    }
    
    func updateCell(message: Message) {
        let duration = "\((message.body?.file?.metaData?.duration ?? 0))" + " s"
        let thumbnailURL = message.body?.thumb?.id?.fullFilePathFromId()
        videoView.setup(duration: duration, thumbnailURL: thumbnailURL)
        
        videoView.thumbnailImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.playVideo)
        }.store(in: &subs)
    }
    
    func setTempThumbnail(duration: String, url: URL?) {
        videoView.setup(duration: duration, thumbnailURL: url)
    }
}
