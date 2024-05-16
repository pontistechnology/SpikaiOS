//
//  MessageImageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageImageView: UIView {
    
    private let imageView = UIImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?
    
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
    }
    
    func positionSubviews() {
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 246)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 246)
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true
    }
}

extension MessageImageView {
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
    
    func setImage(url: URL?, as ratio: ImageRatio) {
        setRatio(to: ratio)
        imageView.kf.setImage(with: url, placeholder: UIImage(resource: .rDloadingPlaceholder))
    }
    
    func setImage(path: String, as ratio: ImageRatio) {
        setRatio(to: ratio)
        imageView.image = UIImage(contentsOfFile: path)
    }
    
    func reset() {
        imageView.image = nil
    }
}

enum ImageRatio {
    case portrait
    case landscape
    case square
    
    init(width: Int64, height: Int64) {
        let width = Float(width)
        let height = Float(height)
        let ratio = width / height
        if 0.75...1.25 ~= ratio {
            self = .square
        } else if ratio > 1.25 {
            self = .landscape
        } else {
            self = .portrait
        }
    }
}
