//
//  MessageVideoView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageVideoView: UIView {
    let thumbnailImageView = UIImageView()
    private let playVideoIconImageView = UIImageView(image: UIImage(safeImage: .playVideo))
    private let durationLabel = CustomLabel(text: "", textColor: .white)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageVideoView: BaseView {
    func addSubviews() {
        addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(playVideoIconImageView)
        thumbnailImageView.addSubview(durationLabel)
    }
    
    func styleSubviews() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
    }
    
    func positionSubviews() {
        thumbnailImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        thumbnailImageView.constrainHeight(256)
        thumbnailImageView.constrainWidth(256)
        
        playVideoIconImageView.centerInSuperview(size: CGSize(width: 48, height: 48))
        
        durationLabel.anchor(bottom: thumbnailImageView.bottomAnchor, trailing: thumbnailImageView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 4))
    }
}

extension MessageVideoView {
    func setup(duration: String) {
        durationLabel.text = duration
        
        // TODO: handle thumbnail when is ready on server
//        thumbnailImageView.kf.setImage(with: URL(string: message.body?.file?.path?.getAvatarUrl() ?? "error"), placeholder: UIImage(systemName: "arrow.counterclockwise")?.withTintColor(.gray, renderingMode: .alwaysOriginal))
    }
    
    func reset() {
        durationLabel.text = nil
    }
}
