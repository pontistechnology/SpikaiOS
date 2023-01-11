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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(reactionsView)
        setupBindings()
    }
}

extension ReactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = ["😂","😇","😍","😘","❤️"]
        return s[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath)
    }
    
    func setupBindings() {
        reactionsView.tableView.delegate = self
        reactionsView.tableView.dataSource = self
    }
}
