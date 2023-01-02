//
//  NewGroupChatViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatViewController: BaseViewController {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
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
        self.viewModel.selectedUsers
            .sink { [weak self] users in
                self?.newGroupChatView.chatMembersView.updateWithUsers(users: users.map { RoomUser(user: $0) })
            }.store(in: &self.viewModel.subscriptions)
        
        self.newGroupChatView.chatMembersView
            .onRemoveUser
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.viewModel.removeUser(user: user)
            }.store(in: &self.viewModel.subscriptions)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .getStringFor(.create), style: .plain, target: self, action: #selector(createButtonHandler))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        newGroupChatView.groupNameTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func setupView(_ view: UIView) {
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.constraint()
        
        self.scrollView.addSubview(view)
        view.constraintToGuide(guide: self.scrollView.contentLayoutGuide)
        view.equalWidth(to: self.view)
    }
    
    @objc func createButtonHandler() {
        guard let name = newGroupChatView.groupNameTextfield.text else { return }
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
