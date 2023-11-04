//
//  DocsTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit

class DocsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "DocsTableViewCell"
    
    let docNameLabel = CustomLabel(text: "this is default text for cell", textColor: .checkWithDesign)
    let leftImageView = UIImageView(image: UIImage(safeImage: .docs))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(leftImageView)
        addSubview(docNameLabel)
    }
    
    func styleSubviews() {
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 6
        leftImageView.backgroundColor = .checkWithDesign
        docNameLabel.numberOfLines = 2
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 46, height: 46))
        
        docNameLabel.anchor(leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 20))
        docNameLabel.centerYToSuperview()
        
    }
    
    func configureCell(image: UIImage, name: String, desc: String) {
        leftImageView.image = image
        docNameLabel.text = name
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(safeImage: .docs)
        docNameLabel.text = ""
    }
}
