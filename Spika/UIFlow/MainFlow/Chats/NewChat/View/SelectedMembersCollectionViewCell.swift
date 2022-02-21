//
//  SelectedMembersCollectionViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//
import UIKit

class SelectedMembersCollectionViewCell: UICollectionViewCell, BaseView {
    
    static let reuseIdentifier: String = "SelectedMembersCollectionViewCell"

    let testLabel = CustomLabel(text: "SelectedMembersCollectionViewCell collection")
    let imageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        addSubview(imageView)
    }
    
    func styleSubviews() {
        backgroundColor = .red
        imageView.image = UIImage(named: "matejVida")
    }
    
    func positionSubviews() {
        imageView.fillSuperview()
    }
}
