//
//  MediaView.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.02.2022..
//

import Foundation
import UIKit

class MediaView: UIView, BaseView {
    
    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        collectionView.register(MediaCollectionViewCell.self, forCellWithReuseIdentifier: MediaCollectionViewCell.reuseIdentifier )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(collectionView)
    }
    
    func styleSubviews() {
        backgroundColor = .orange
    }
    
    func positionSubviews() {
        collectionView.fillSuperview()
    }
}
