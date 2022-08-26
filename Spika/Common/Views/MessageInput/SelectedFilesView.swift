//
//  SelectedFilesView.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.08.2022..
//

import UIKit
import Combine
import AVFoundation

class SelectedFilesView: UIView {
    private let moreActionsLabel = CustomLabel(text: "Selected Items", textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    let itemsStackView = UIStackView()
    private let scrollView = UIScrollView()
    let height: CGFloat = 120.0
    
    init(){
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectedFilesView: BaseView {
    func addSubviews() {
        addSubview(scrollView)
        addSubview(moreActionsLabel)
        scrollView.addSubview(itemsStackView)
    }
    
    func styleSubviews() {
        backgroundColor = .lightGray
        itemsStackView.axis = .horizontal
        itemsStackView.spacing = 6
        itemsStackView.distribution = .fillEqually
    }
    
    func positionSubviews() {
        moreActionsLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 0))
        
        scrollView.anchor(top: moreActionsLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        
        itemsStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        itemsStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
}

extension SelectedFilesView {
    func showFiles(_ files: [SelectedFile]) {
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        files.forEach {
            let iw = SelectedFileImageView(image: $0.thumbnail, fileName: $0.name)
            itemsStackView.addArrangedSubview(iw)
        }
    }
}
