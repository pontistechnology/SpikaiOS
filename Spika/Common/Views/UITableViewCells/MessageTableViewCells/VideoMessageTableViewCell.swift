//
//  VideoMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.11.2022..
//

import UIKit

final class VideoMessageTableViewCell: BaseMessageTableViewCell {
    
    private let thumbnailImageView = UIImageView()
    private let playVideoIconImageView = UIImageView(image: UIImage(safeImage: .playVideo))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupVideoCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVideoCell() {
        containerView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(playVideoIconImageView)
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        
        thumbnailImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        thumbnailImageView.constrainHeight(256)
        thumbnailImageView.constrainWidth(256)
        
        playVideoIconImageView.centerInSuperview(size: CGSize(width: 48, height: 48))
    }
}

extension VideoMessageTableViewCell {
    func updateCell(message: Message) {
        // TODO: handle thumbnail when is ready on server
//        thumbnailImageView.kf.setImage(with: URL(string: message.body?.file?.path?.getAvatarUrl() ?? "error"), placeholder: UIImage(systemName: "arrow.counterclockwise")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        
        thumbnailImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.playVideo)
        }.store(in: &subs)
    }
}
