//
//  MediaView.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.02.2022..
//

import Foundation
import UIKit

class LinksView: UIView, BaseView {

    let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        tableView.register(LinksTableViewCell.self, forCellReuseIdentifier: LinksTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(tableView)
    }
    
    func styleSubviews() {
        tableView.separatorColor = .clear
    }
    
    func positionSubviews() {
        tableView.fillSuperview()
        tableView.rowHeight = 62
    }
    

    

}
