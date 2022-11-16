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
    private let durationLabel = CustomLabel(text: "", textColor: .white)
    
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
        thumbnailImageView.addSubview(durationLabel)
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        
        thumbnailImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        thumbnailImageView.constrainHeight(256)
        thumbnailImageView.constrainWidth(256)
        
        playVideoIconImageView.centerInSuperview(size: CGSize(width: 48, height: 48))
        durationLabel.anchor(bottom: thumbnailImageView.bottomAnchor, trailing: thumbnailImageView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 4))
    }
}

extension VideoMessageTableViewCell {
    func updateCell(message: Message) {
        // TODO: handle thumbnail when is ready on server
//        thumbnailImageView.kf.setImage(with: URL(string: message.body?.file?.path?.getAvatarUrl() ?? "error"), placeholder: UIImage(systemName: "arrow.counterclockwise")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
        
        // TODO: Change to duration later, for now is size
        durationLabel.text = "\((message.body?.file?.size ?? 0) / 1000000)" + " MB"
        
        thumbnailImageView.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.playVideo)
        }.store(in: &subs)
    }
}
