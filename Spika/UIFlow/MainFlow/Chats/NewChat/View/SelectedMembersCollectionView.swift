//
//  SelectedMembersCollectionView.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//
import UIKit

class SelectedMembersCollectionView: UICollectionView, BaseView {
    
    let a = CustomLabel(text: "0/100 selected", textSize: 11, textColor: .textPrimaryAndWhite)
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        setupView()
        register(SelectedMembersCollectionViewCell.self, forCellWithReuseIdentifier: SelectedMembersCollectionViewCell.reuseIdentifier)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
       addSubview(a)
    }
    
    func styleSubviews() {
        backgroundColor = .orange
    }
    
    func positionSubviews() {
        a.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
