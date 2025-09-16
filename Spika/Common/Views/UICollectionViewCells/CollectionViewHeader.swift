//
//  CollectionViewHeader.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.08.2023..
//

import Foundation
import UIKit

class CollectionViewHeader: UICollectionReusableView {
    private let titleLabel = CustomLabel(text: "s", textSize: 12, textColor: .textSecondary, fontName: .RobotoFlexMedium)
    static let reuseIdentifier = "CollectionViewHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionViewHeader: BaseView {
    func addSubviews() {
        addSubview(titleLabel)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func configureView(title: String) {
        titleLabel.text = title
    }
}

