//
//  BackgroundButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class ImageViewWithIcon: UIView, BaseView {
    
    private let backgroundView = UIView()
    private let mainImageView = UIImageView()
    private let plainImageView = UIImageView()
    private let cameraIcon = ImageButton(image: UIImage(safeImage: .camera), size: CGSize(width: 28, height: 28)) // TODO: camera background
    private let uploadProgressView = CircularProgressBar(spinnerWidth: 24)
    
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
        backgroundView.addSubview(plainImageView)
        backgroundView.addSubview(mainImageView)
        addSubview(cameraIcon)
    }
    
    func styleSubviews() {
        backgroundView.backgroundColor = .checkWithDesign // TODO: - check
        backgroundView.layer.cornerRadius = size.height / 2
        backgroundView.clipsToBounds = true
        
        plainImageView.image = UIImage(safeImage: .camera)
        plainImageView.contentMode = .scaleAspectFit

        mainImageView.image = image
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.hide()
        cameraIcon.hide()
    }
    
    func positionSubviews() {
        backgroundView.fillSuperview()
        backgroundView.anchor(size: size)
        
        mainImageView.centerInSuperview()
        mainImageView.anchor(size: CGSize(width: size.width, height: size.height))
        
        plainImageView.centerInSuperview()
        plainImageView.anchor(size: CGSize(width: size.width * 0.4, height: size.height * 0.4))
        
        cameraIcon.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func deleteMainImage() {
        plainImageView.unhide()
        mainImageView.isHidden  = true
        cameraIcon.hide()
    }
    
    func showImage(_ image: UIImage) {
        plainImageView.hide()
        
        mainImageView.image = image
        mainImageView.isHidden  = false
        cameraIcon.unhide()
    }
    
    func showImage(_ url: URL, placeholder: UIImage?) {
        plainImageView.hide()
        
        mainImageView.kf.setImage(with: url, placeholder: placeholder)
        mainImageView.isHidden  = false
        cameraIcon.unhide()
    }
    
    func showUploadProgress(progress: CGFloat) {
        if let _ = uploadProgressView.superview {
            
        } else {
            backgroundView.addSubview(uploadProgressView)
            uploadProgressView.fillSuperview()            
        }
        uploadProgressView.setProgress(to: progress)
        isUserInteractionEnabled = false
    }
    
    func hideUploadProgress() {
        uploadProgressView.removeFromSuperview()
        isUserInteractionEnabled = true
    }
    
    func updateCameraIsHidden(isHidden: Bool) {
        self.cameraIcon.isHidden = isHidden
    }
    
}
