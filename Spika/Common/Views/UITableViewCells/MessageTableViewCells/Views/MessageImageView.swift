//
//  MessageImageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageImageView: UIView {
    
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageImageView: BaseView {
    func addSubviews() {
        addSubview(imageView)
    }
    
    func styleSubviews() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    func positionSubviews() {
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        imageView.constrainWidth(256)
        imageView.constrainHeight(256)
    }
}

extension MessageImageView {
    func setImage(url: URL?) {
        imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "arrow.counterclockwise")?.withTintColor(.gray, renderingMode: .alwaysOriginal)) // TODO: change image
    }
    
    func reset() {
        imageView.image = nil
    }
}
