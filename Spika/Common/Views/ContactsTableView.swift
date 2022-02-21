//
//  test.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit

class ContactsTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTV()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTV() {
        register(ContactsTableViewCell.self, forCellReuseIdentifier: ContactsTableViewCell.reuseIdentifier)
        rowHeight = 64
    }
}
