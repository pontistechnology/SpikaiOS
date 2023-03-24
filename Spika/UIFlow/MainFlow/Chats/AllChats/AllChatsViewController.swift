//
//  ChatsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import CoreData
import UIKit

class AllChatsViewController: BaseViewController {
    
    private let allChatsView = AllChatsView()
    var viewModel: AllChatsViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(allChatsView)
        setupBindings()
    }
    
    func setupBindings() {
        allChatsView.allChatsTableView.delegate = self
        allChatsView.allChatsTableView.dataSource = self
        allChatsView.searchBar.delegate = self
        
        allChatsView.newChatButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
        }.store(in: &subscriptions)
        
        allChatsView.newChatButton
            .tap()
            .sink { [weak self] _ in
                self?.onCreateNewRoom()
            }.store(in: &self.subscriptions)
        
        viewModel.setRoomsFetch()
        viewModel.frc?.delegate = self
        allChatsView.allChatsTableView.reloadData()
    }
    
    func onCreateNewRoom() {
        self.viewModel.getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: [])
    }
    
}

// MARK: - NSFetchedResultsController

extension AllChatsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        allChatsView.allChatsTableView.reloadData()
    }
}

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let room = viewModel.getRoom(for: indexPath) else { return }
        print("ROOM selected: ", room)
        viewModel.presentCurrentChatScreen(room: room)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = viewModel.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
        guard let room = viewModel.getRoom(for: indexPath) else { return EmptyTableViewCell()}
    
        let lastMessage = viewModel.repository.getLastMessage(roomId: room.id)
        let badgeNumber = 2 // TODO: - unread count
        if room.type == .privateRoom,
           let friendUser = room.getFriendUserInPrivateRoom(myUserId: viewModel.getMyUserId()) {
            cell?.configureCell(avatarUrl: friendUser.avatarFileId?.fullFilePathFromId(),
                                name: friendUser.getDisplayName(),
                                description: viewModel.description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber,
                                muted: room.muted,
                                pinned: room.pinned)
            
        } else if room.type != .privateRoom {
            
            cell?.configureCell(avatarUrl: room.avatarFileId?.fullFilePathFromId(),
                                name: room.name ?? .getStringFor(.noName),
                                description: viewModel.description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber,
                                muted: room.muted,
                                pinned: room.pinned)
        }
        
        return cell ?? EmptyTableViewCell()
    }
}

// MARK: UITableview swipe animations, ignore for now
extension AllChatsViewController {
    
    private func printSwipe() {
        print("Swipe.")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstLeft = UIContextualAction(style: .normal, title: "First left") { [weak self] (action, view, completionHandler) in
                self?.printSwipe()
                completionHandler(true)
            }
        firstLeft.backgroundColor = .systemBlue
        
        let secondLeft = UIContextualAction(style: .normal, title: "Second left") { [weak self] (action, view, completionHandler) in
                self?.printSwipe()
                completionHandler(true)
            }
        secondLeft.backgroundColor = .systemPink
        
        let configuration = UISwipeActionsConfiguration(actions: [firstLeft, secondLeft])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRightAction = UIContextualAction(style: .normal, title: "First Right") { [weak self] (action, view, completionHandler) in
                self?.printSwipe()
                completionHandler(true)
            }
        firstRightAction.backgroundColor = .systemGreen
        
        let secondRightAction = UIContextualAction(style: .destructive, title: "Second Right") { [weak self] (action, view, completionHandler) in
                self?.printSwipe()
                completionHandler(true)
            }
        secondRightAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [secondRightAction, firstRightAction])
    }
}

extension AllChatsViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        if let value = value {
            self.viewModel.changePredicate(to: value)
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        viewModel.changePredicate(to: "")
        allChatsView.allChatsTableView.reloadData()
    }
}
