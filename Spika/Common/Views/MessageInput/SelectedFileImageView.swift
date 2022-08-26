//
//  SelectedFileImageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.08.2022..
//

import Foundation
import UIKit

struct FileIcon {
    
}

class SelectedFileImageView: UIImageView {
    
    let deleteImageView = UIImageView(image: UIImage(named: "deleteCell"))
    let fileNameLabel = CustomLabel(text: "fileName", textSize: 10, textColor: .textPrimary, fontName: .MontserratRegular)
    private let progressView = CircularProgressBar(spinnerWidth: 20)
    
    init(image: UIImage?, fileName: String? = nil) {
        super.init(image: image)
        setupView()
        setFileName(fileName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectedFileImageView: BaseView {
    func addSubviews() {
        addSubview(deleteImageView)
        addSubview(fileNameLabel)
    }
    
    func styleSubviews() {
        backgroundColor = .chatBackground
        isUserInteractionEnabled = true
        layer.cornerRadius = 10
        clipsToBounds = true
        contentMode = .scaleAspectFit
    }
    
    func positionSubviews() {
        constrainWidth(72)
        constrainHeight(72)
        
        deleteImageView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        fileNameLabel.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4))
    }
    
    func setFileName(_ name: String?) {
        fileNameLabel.text = name
    }
}

extension SelectedFileImageView {
    func showUploadProgress(progress: CGFloat) {
        if let _ = progressView.superview {
            
        } else {
            addSubview(progressView)
            progressView.fillSuperview()
        }
        progressView.setProgress(to: progress)
        isUserInteractionEnabled = false
    }
    
    func hideUploadProgress() {
        progressView.removeFromSuperview()
        isUserInteractionEnabled = true
    }
}
