//
//  NewGroupChatViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatViewController: BaseViewController {
    
    private let newGroupChatView = NewGroupChatView()
    var viewModel: NewGroupChatViewModel!
    private let imagePicker = UIImagePickerController()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(newGroupChatView)
        setupBindings()
    }
    
    func setupBindings() {
        newGroupChatView.selectedUsersTableView.delegate = self
        newGroupChatView.selectedUsersTableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .getStringFor(.create), style: .plain, target: self, action: #selector(createButtonHandler))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        newGroupChatView.usernameTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func createButtonHandler() {
        guard let name = newGroupChatView.usernameTextfield.text else { return }
        viewModel.createRoom(name: name)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let length = textField.text?.count, length > 3 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

extension NewGroupChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.selectedUsers.count > 1 {
            viewModel.selectedUsers.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
}

extension NewGroupChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newGroupChatView.numberOfUsersLabel.text = "\(viewModel.selectedUsers.count) " + .getStringFor(.peopleSelected)
        return viewModel.selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        cell?.configureCell(viewModel.selectedUsers[indexPath.row])
        return cell ?? EmptyTableViewCell()
    }
}
