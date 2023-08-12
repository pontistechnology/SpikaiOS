//
//  CustomReactionsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation
import UIKit

class CustomReactionsView: UIView {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init() {
        super.init(frame: .zero)
        setupView()
        collectionView.register(CustomReactionCollectionViewCell.self, forCellWithReuseIdentifier: CustomReactionCollectionViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var calculatedSpacing: CGFloat {
        let numberOfCellsInOneRow: CGFloat = 7 // change this only
        return (collectionView.frame.width - numberOfCellsInOneRow * CustomReactionCollectionViewCell.widthOrHeight) / (numberOfCellsInOneRow - 1)
    }
}

extension CustomReactionsView: BaseView {
    func addSubviews() {
        addSubview(collectionView)
    }
    
    func styleSubviews() {
        collectionView.backgroundColor = .green
    }
    
    func positionSubviews() {
        collectionView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
}
