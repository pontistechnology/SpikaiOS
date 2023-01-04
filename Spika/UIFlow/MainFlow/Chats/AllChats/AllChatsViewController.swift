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
    var frc: NSFetchedResultsController<RoomEntity>?
    
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
        
        allChatsView.pencilImageView.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
        }.store(in: &subscriptions)
        
        allChatsView.pencilImageView
            .tap()
            .sink { [weak self] _ in
                self?.onCreateNewRoom()
            }.store(in: &self.subscriptions)
        
        setRoomsFetch()
        
        self.viewModel.repository
            .unreadRoomsPublisher
            .sink { [weak self] string in
                self?.navigationController?.navigationItem.backBarButtonItem =
                UIBarButtonItem(title:.getStringFor(.title), style:.plain, target:nil, action:nil)
            }.store(in: &self.subscriptions)
    }
    
    func onCreateNewRoom() {
        self.viewModel.getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: [])
    }
    
}

// MARK: - NSFetchedResultsController

extension AllChatsViewController: NSFetchedResultsControllerDelegate {
    
    func setRoomsFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = RoomEntity.fetchRequest()
            fetchRequest.predicate = self.viewModel.defaultChatsPredicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp),
                                                             ascending: false),
                                            NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                  managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            do {
                try self.frc?.performFetch()
                self.allChatsView.allChatsTableView.reloadData()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
                // TODO: handle error and change main context to func
            }
 
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        allChatsView.allChatsTableView.reloadData()
    }
}

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let roomEntity = frc?.object(at: indexPath) else { return }
        let room = Room(roomEntity: roomEntity)
        print("ROOM selected: ", room)
        viewModel.presentCurrentChatScreen(room: room)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
        guard let entity = frc?.object(at: indexPath) else { return EmptyTableViewCell()}
    
        let room = Room(roomEntity: entity)
        
        let badgeNumber = entity.numberOfUnreadMessages(myUserId: viewModel.getMyUserId())
        if room.type == .privateRoom,
           let friendUser = room.getFriendUserInPrivateRoom(myUserId: viewModel.getMyUserId()) {
            cell?.configureCell(avatarUrl: friendUser.getAvatarUrl(),
                                name: friendUser.getDisplayName(),
                                description: entity.lastMessageText(),
                                time: entity.lastMessageTime(),
                                badgeNumber: badgeNumber)
            
        } else if room.type != .privateRoom {
            
            cell?.configureCell(avatarUrl: room.getAvatarUrl(),
                                name: room.name ?? .getStringFor(.noName),
                                description: entity.lastMessageText(),
                                time: entity.lastMessageTime(),
                                badgeNumber: badgeNumber)
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
            self.changePredicate(to: value)
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        self.changePredicate(to: "")
    }
    
    func changePredicate(to newString: String) {
        let searchPredicate = newString.isEmpty ? self.viewModel.defaultChatsPredicate : NSPredicate(format: "name CONTAINS[c] '\(newString)' and roomDeleted = false")
        self.frc?.fetchRequest.predicate = searchPredicate
        try? self.frc?.performFetch()
        self.allChatsView.allChatsTableView.reloadData()
    }
}
