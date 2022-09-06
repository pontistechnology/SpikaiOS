//
//  LinksTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit

class LinksTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "LinksTableViewCell"
    
    let titleLabel = CustomLabel(text: "this is default text for cell", textSize: 11)
    let linkLabel  = CustomLabel(text: "www.defaultfsajofiajsoidfjoiasjodifjiosajdoifjsoaidjfoisafoijasidfjolink.com", textSize: 9, textColor: .textTertiary)
    let leftImageView = UIImageView(image: .docs)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(leftImageView)
        addSubview(titleLabel)
        addSubview(linkLabel)
    }
    
    func styleSubviews() {
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 6
        leftImageView.backgroundColor = .appBlueLight
        linkLabel.numberOfLines = 2
        titleLabel.numberOfLines = 1
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 46, height: 46))
        
        titleLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 20))
        
        linkLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, trailing: titleLabel.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        
        
    }
    
    func configureCell(image: UIImage, name: String, desc: String) {
        leftImageView.image = image
        
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(systemName: "house")
        
    }
}
