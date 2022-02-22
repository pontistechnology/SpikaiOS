//
//  NewChatViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import UIKit

class NewChatViewController: BaseViewController {
    
    private let newChatView = NewChatView()
    var viewModel: NewChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(newChatView)
        setupBindings()
    }
    
    func setupBindings() {
        newChatView.contactsTableView.delegate = self
        newChatView.contactsTableView.dataSource = self
        newChatView.groupMembersCollectionView.delegate = self
        newChatView.groupMembersCollectionView.dataSource = self
        
        newChatView.cancelLabel.tap().sink { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        newChatView.chatOptionLabel.tap().sink { _ in
            self.newChatView.setGroupMemberVisible(self.newChatView.groupMembersCollectionView.isHidden ? true : false)
        }.store(in: &subscriptions)
    }
}

extension NewChatViewController: UITableViewDelegate {
    private func printSwipe() {
        print("Swipe.")
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleMoveToArchive() {
        print("Moved to archive")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstLeft = UIContextualAction(style: .normal, title: "First left") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        firstLeft.backgroundColor = .systemBlue
        
        let secondLeft = UIContextualAction(style: .normal, title: "Second left") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        secondLeft.backgroundColor = .systemPink
        
        let configuration = UISwipeActionsConfiguration(actions: [firstLeft, secondLeft])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRightAction = UIContextualAction(style: .normal, title: "First Right") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        firstRightAction.backgroundColor = .systemGreen
        
        let secondRightAction = UIContextualAction(style: .destructive, title: "Second Right") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        secondRightAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [secondRightAction, firstRightAction])
    }
}

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier) as? ContactsTableViewCell
        cell?.configureCell(image: UIImage(named: "matejVida")!, name: "Matej Vida", desc: "junior iOs dev")
        return cell ?? UITableViewCell()
    }
}

extension NewChatViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: SelectedMembersCollectionViewCell.reuseIdentifier, for: indexPath)
    }
}

extension NewChatViewController: UICollectionViewDelegate {
    
}

extension NewChatViewController: UICollectionViewDelegateFlowLayout {
    
}


