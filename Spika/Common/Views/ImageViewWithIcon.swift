//
//  BackgroundButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class ImageViewWithIcon: UIView, BaseView {
    
    private let mainImageView = UIImageView()
    private let uploadProgressView = CircularProgressBar(spinnerWidth: 24)
    
    private let image: UIImage
    private let size: CGSize
    
    init(image: UIImage, size: CGSize = CGSize(width: 44, height: 44)) {
        self.image = image
        self.size = size
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(mainImageView)
    }
    
    func styleSubviews() {
        mainImageView.image = image
        mainImageView.contentMode = .scaleAspectFill
//        mainImageView.hide()
    }
    
    func positionSubviews() {
        mainImageView.fillSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.bottomLeft], radius: 80)
    }
    
    func deleteMainImage() {
        mainImageView.isHidden  = true
    }
    
    func showImage(_ image: UIImage) {
        mainImageView.image = image
        mainImageView.isHidden  = false
    }
    
    func showImage(_ url: URL, placeholder: UIImage?) {
        mainImageView.kf.setImage(with: url, placeholder: placeholder)
        mainImageView.isHidden  = false
    }
    
    func showUploadProgress(progress: CGFloat) {
        if let _ = uploadProgressView.superview {
            
        } else {
            addSubview(uploadProgressView)
            uploadProgressView.fillSuperview()            
        }
        uploadProgressView.setProgress(to: progress)
        isUserInteractionEnabled = false
    }
    
    func hideUploadProgress() {
        uploadProgressView.removeFromSuperview()
        isUserInteractionEnabled = true
    }
}
