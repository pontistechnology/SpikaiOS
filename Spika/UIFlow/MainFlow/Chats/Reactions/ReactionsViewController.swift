//
//  ReactionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.01.2023..
//

import Foundation
import UIKit

class ReactionsViewController: BaseViewController {
    private let reactionsView = ReactionsView()
    private let records: [MessageRecord]
    private let users: [User]
    
    init(users: [User], records: [MessageRecord]) {
        self.records = records
        self.users = users
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(reactionsView)
        setupBindings()
    }
}

extension ReactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        21
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        else { return EmptyTableViewCell()}
        
        cell.configureCell(title: "User name", description: "description", leftImage: nil, type: .emoji(emoji: "😂", size: 32))
        
        return cell
    }
    
    func setupBindings() {
        reactionsView.tableView.delegate = self
        reactionsView.tableView.dataSource = self
    }
}
