//
//  ChatsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

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
        getAllRooms()
    }
    
    func setupBindings() {
        
        allChatsView.allChatsTableView.delegate = self
        allChatsView.allChatsTableView.dataSource = self
        
        allChatsView.pencilImageView.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
        }.store(in: &subscriptions)
        
        viewModel.roomsPublisher.sink { rooms in
            self.allChatsView.allChatsTableView.reloadData()
        }.store(in: &subscriptions)
    }
    
    func getAllRooms() {
        viewModel.getAllRooms()
    }
    
}

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let room = viewModel.roomsPublisher.value[indexPath.row]
        if room.type == "private" {
            // MARK: TODO: find localuser in db
            
            viewModel.presentCurrentPrivateChatScreen()
        }
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.roomsPublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
        let room = viewModel.roomsPublisher.value[indexPath.row]
        
typeTest: if room.type == "private" {
            guard let friend = room.users.first (where: { user in
                user.user.id != viewModel.getMyUserId()
            }) else { break typeTest }
            
            cell?.configureCell(avatarUrl: room.avatarUrl, name: friend.user.displayName ?? "unknown name", desc: "private room, id: \(room.id)")
        }
        
        return cell ?? UITableViewCell()
    }
}










// MARK: UITableview swipe animations, ignore for now
extension AllChatsViewController {
    
    private func printSwipe() {
        print("Swipe.")
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
