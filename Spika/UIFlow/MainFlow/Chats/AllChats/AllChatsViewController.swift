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
        viewModel.refreshUnreadCounts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(allChatsView)
        setupBindings()
        viewModel.refreshUnreadCounts()
    }
    
    func setupBindings() {
        allChatsView.allChatsTableView.delegate = self
        allChatsView.allChatsTableView.dataSource = self
        allChatsView.searchedMessagesTableView.delegate = self
        allChatsView.searchedMessagesTableView.dataSource = self
        allChatsView.searchBar.delegate = self
        
        allChatsView.newChatButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
        }.store(in: &subscriptions)
        
        allChatsView.newChatButton
            .tap()
            .sink { [weak self] _ in
                self?.onCreateNewRoom()
            }.store(in: &subscriptions)
        
        viewModel.setupBinding()
        viewModel.setRoomsFetch()
        viewModel.setMessagesFetch(searchTerm: "test")
        
        viewModel.rooms
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.allChatsView.allChatsTableView.reloadData()
            }.store(in: &subscriptions)
        
        allChatsView.segmentedControl.addTarget(self, action: #selector(segmentedControlChanges), for: .valueChanged)
    }
    
    // TODO: - move to viewmodel under navigation
    func onCreateNewRoom() {
        viewModel.getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: [])
    }
    
}

// MARK: - UITableview

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == allChatsView.allChatsTableView else { return }
        viewModel.presentCurrentChatScreen(for: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true) // TODO: - check, maybe use tableview keyboard handling method
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rooms.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == allChatsView.searchedMessagesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsSearchedMessageCell.reuseIdentifier, for: indexPath) as? AllChatsSearchedMessageCell
//            guard let data = viewModel.getDataForCell(at: indexPath) else { return EmptyTableViewCell() }
            cell?.configureCell(text: "aa")
            return cell ?? EmptyTableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
            guard let data = viewModel.getDataForCell(at: indexPath) else { return EmptyTableViewCell() }
            cell?.configureCell(avatarUrl: data.avatarUrl, name: data.name,
                                description: data.description, time: data.time,
                                badgeNumber: data.badgeNumber, muted: data.muted, pinned: data.pinned)
            return cell ?? EmptyTableViewCell()
        }
    }
}

// MARK: - UITableview swipe animations, ignore for now

extension AllChatsViewController {
    
    private func printSwipe() {
        print("Swipe.")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView == allChatsView.allChatsTableView else { return nil }
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
        guard tableView == allChatsView.allChatsTableView else { return nil }
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

// MARK: - SearchBarDelegate

extension AllChatsViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        allChatsView.segmentedControl.isHidden = value?.isEmpty ?? true
        viewModel.search.send(value)
        allChatsView.searchedMessagesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        viewModel.search.send(nil)
    }
}

extension AllChatsViewController {
    @objc func segmentedControlChanges() {
        allChatsView.searchedMessagesTableView.isHidden = allChatsView.segmentedControl.selectedSegmentIndex == 0
        allChatsView.allChatsTableView.isHidden = allChatsView.segmentedControl.selectedSegmentIndex == 1
    }
}
