//
//  BackgroundButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class ImageButton: UIView, BaseView {
    
    let backgroundView = UIView()
    let imageView = UIImageView()
    
    private let image: UIImage
    private let size: CGSize
    
    init(image: UIImage, size: CGSize = CGSize(width: 44, height: 44)) {
        self.image = image
        self.size = size
        super.init(frame: CGRect(x: .zero, y: .zero, width: size.width, height: size.height))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(backgroundView)
        addSubview(imageView)
    }
    
    func styleSubviews() {
        backgroundView.backgroundColor = .appBlueLight
        backgroundView.layer.cornerRadius = size.height / 2
        backgroundView.clipsToBounds = true
        
        imageView.image = image.withRenderingMode(.alwaysOriginal)
    }
    
    func positionSubviews() {
        backgroundView.fillSuperview()
        backgroundView.anchor(size: size)
        
        imageView.centerInSuperview()
        imageView.anchor(size: CGSize(width: size.width * 0.6, height: size.height * 0.6))
    }
    
}
