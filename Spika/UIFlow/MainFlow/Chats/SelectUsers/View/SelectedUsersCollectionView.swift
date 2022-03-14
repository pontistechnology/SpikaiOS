//
//  SelectedUsersCollectionView.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//
import UIKit

class SelectedUsersCollectionView: UICollectionView, BaseView {
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        setupView()
        register(SelectedUsersCollectionViewCell.self, forCellWithReuseIdentifier: SelectedUsersCollectionViewCell.reuseIdentifier)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
    }
    
    func styleSubviews() {
        backgroundColor = .orange
    }
    
    func positionSubviews() {
    }

}
