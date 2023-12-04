//
//  VideoMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.11.2022..
//

import UIKit

final class VideoMessageTableViewCell: BaseMessageTableViewCell2 {
    
    private let videoView = MessageVideoView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupVideoCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVideoCell() {
        hSTack.addArrangedSubview(videoView)
    }
}

extension VideoMessageTableViewCell: BaseMessageTableViewCellProtocol {
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.reset()
    }
    
    func updateCell(message: Message) {
        let ratio = ImageRatio(width: message.body?.thumb?.metaData?.width ?? 1,
                               height: message.body?.thumb?.metaData?.height ?? 1)
        
        let url: URL?
        // TODO: -  move to rep
        if let localId = message.localId,
           let localUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent(localId+"thumb.jpg"),
           FileManager.default.fileExists(atPath: localUrl.path) {
            url = localUrl
        } else {
            url = message.body?.thumb?.id?.fullFilePathFromId()
        }
        videoView.setup(duration: message.body?.file?.metaData?.duration,
                        thumbnailURL: url, as: ratio)
        
        videoView.thumbnailImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.playVideo)
        }.store(in: &subs)
    }
}
