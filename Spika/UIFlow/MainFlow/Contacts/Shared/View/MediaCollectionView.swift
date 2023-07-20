//
//  MediaCollectionView.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.02.2022..
//

import Foundation
import UIKit

class MediaCollectionView: UICollectionView, BaseView {
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        setupView()
        register(MediaCollectionViewCell.self, forCellWithReuseIdentifier: MediaCollectionViewCell.reuseIdentifier)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
       
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
    }
}
