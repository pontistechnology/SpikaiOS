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
        allChatsView.allChatsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(allChatsView)
        setupBindings()
    }
    
    func setupBindings() {
        
        allChatsView.allChatsTableView.delegate = self
        allChatsView.allChatsTableView.dataSource = self
        
        allChatsView.pencilImageView.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
            self?.getAllRooms()
        }.store(in: &subscriptions)
        
        setRoomsFetch()
    
    }
    
    func getAllRooms() {
        viewModel.getAllRooms()
    }
    
}

// MARK: - NSFetchedResultsController

extension AllChatsViewController: NSFetchedResultsControllerDelegate {
    
    func setRoomsFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = RoomEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)' OR messages.@count > 0")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false)]
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
//        tableView.deselectRow(at: indexPath, animated: true)
        guard let entity = frc?.object(at: indexPath) else { return }
        let room = Room(roomEntity: entity)
        print("ROOM_: ", room)
        viewModel.presentCurrentChatScreen(room: room)
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
        guard let entity = frc?.object(at: indexPath) else { return UITableViewCell()}
        print("ALLCVC: ", indexPath, " roomentity: ", entity)
    
        let room = Room(roomEntity: entity)
        print("room at indexpath: ", indexPath, room)
        let messagesEntities = (entity.messages?.array as! [MessageEntity]).filter{$0.createdAt > entity.visitedRoom && $0.fromUserId != viewModel.getMyUserId()}
        for m in messagesEntities {
            print("mmm \(messagesEntities.firstIndex(of: m)):  createdat: ", m.createdAt, " text: ", m.bodyText, " from userid: ", m.fromUserId, "entitiy visited: ", entity.visitedRoom)
        }
        let badgeNumber = messagesEntities.count
        if room.type == .privateRoom,
           let friendRoomUser = room.users.first(where: { roomUser in
               roomUser.user.id != viewModel.getMyUserId()
           })
        {
            let friendUser = friendRoomUser.user
            cell?.configureCell(avatarUrl: friendUser.getAvatarUrl(),
                                name: friendUser.getDisplayName(),
                                description: (entity.messages?.lastObject as? MessageEntity)?.bodyText ?? "No messages",
                                time: (entity.messages?.lastObject as? MessageEntity)?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber)
        }
        
        if room.type != .privateRoom {
            let lastMessage = entity.messages?.lastObject as? MessageEntity
            let senderName = room.users.first(where: { ru in
                ru.userId == lastMessage?.fromUserId
            })?.user.getDisplayName() ?? "no name"
            
            cell?.configureCell(avatarUrl: room.getAvatarUrl(),
                                name: room.name ?? "noname",
                                description: senderName + ": " + (lastMessage?.bodyText ?? "no messages"),
                                time: (entity.messages?.lastObject as? MessageEntity)?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: badgeNumber)
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
