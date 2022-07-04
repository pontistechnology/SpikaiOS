//
//  MessageDetailsView.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.05.2022..
//

import Foundation
import UIKit

class MessageDetailsView: UIView {
    
    private let detailsLabel = CustomLabel(text: "Details", textSize: 16, textColor: .textPrimary, fontName: .MontserratSemiBold)
    let recordsTableView = UITableView()
    
    init() {
        super.init(frame: .zero)
        setupView()
        recordsTableView.register(MessageDetailTableViewCell.self, forCellReuseIdentifier: MessageDetailTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageDetailsView: BaseView {
    func addSubviews() {
        addSubview(detailsLabel)
        addSubview(recordsTableView)
    }
    
    func styleSubviews() {
        backgroundColor = .white
        recordsTableView.backgroundColor = .white
    }
    
    func positionSubviews() {
        detailsLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 0))
        
        recordsTableView.anchor(top: detailsLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
    }
}
