//
//  MediaCollectionViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.02.2022..
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell, BaseView {
    
    static let reuseIdentifier: String = "MediaCollectionViewCell"

    let testLabel = CustomLabel(text: "collection", textColor: .checkWithDesign)
    let imageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
//        addSubview(testLabel)
        addSubview(imageView)
    }
    
    func styleSubviews() {
        backgroundColor = .red
        imageView.image = UIImage(safeImage: .testImage)
    }
    
    func positionSubviews() {
//        testLabel.centerInSuperview()
        imageView.fillSuperview()
    }
}
