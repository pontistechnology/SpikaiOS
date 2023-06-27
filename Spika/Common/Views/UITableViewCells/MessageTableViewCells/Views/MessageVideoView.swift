//
//  MessageVideoView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageVideoView: UIView {
    let thumbnailImageView = UIImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    
    private let playVideoIconImageView = UIImageView(image: UIImage(safeImage: .playVideo))
    private let durationLabel = CustomLabel(text: "", textColor: .primaryBackground)
    
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
        imageWidthConstraint = thumbnailImageView.widthAnchor.constraint(equalToConstant: 246)
        imageHeightConstraint = thumbnailImageView.heightAnchor.constraint(equalToConstant: 246)
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true
        
        playVideoIconImageView.centerInSuperview(size: CGSize(width: 48, height: 48))
        
        durationLabel.anchor(bottom: thumbnailImageView.bottomAnchor, trailing: thumbnailImageView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 4))
    }
}

extension MessageVideoView {
    
    private func setRatio(to ratio: ImageRatio) {
        switch ratio {
        case .portrait:
            imageWidthConstraint?.constant = 140
            imageHeightConstraint?.constant = 246
        case .landscape:
            imageWidthConstraint?.constant = 240
            imageHeightConstraint?.constant = 114
        case .square:
            imageWidthConstraint?.constant = 246
            imageHeightConstraint?.constant = 246
        }
    }
    
    func setup(duration: Int64?, thumbnailURL: URL?, as ratio: ImageRatio) {
        setRatio(to: ratio)
        thumbnailImageView.kf.setImage(with: thumbnailURL)
        guard let duration else { return }
        durationLabel.text = "\(duration) s"
    }
    
    func reset() {
        durationLabel.text = nil
    }
}
