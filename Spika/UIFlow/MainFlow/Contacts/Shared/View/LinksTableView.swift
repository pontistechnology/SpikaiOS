//
//  LinksTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.02.2022..
//

import Foundation
import UIKit

class LinksTableView: UITableView, BaseView {
    
    init() {
        super.init(frame: .zero, style: .plain)
        setupView()
        register(LinksTableViewCell.self, forCellReuseIdentifier: LinksTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
    }
    
    func styleSubviews() {
        separatorColor = .clear
    }
    
    func positionSubviews() {
    }
    

    

}
