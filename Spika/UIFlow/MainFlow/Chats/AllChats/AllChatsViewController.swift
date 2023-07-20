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
        allChatsView.roomsTableView.delegate = self
        allChatsView.roomsTableView.dataSource = self
        allChatsView.searchedMessagesTableView.delegate = self
        allChatsView.searchedMessagesTableView.dataSource = self
        allChatsView.searchBar.delegate = self
        
        allChatsView.newChatButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSelectUserScreen()
        }.store(in: &subscriptions)
        
        allChatsView.newChatButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.onCreateNewRoom()
            }.store(in: &subscriptions)
        
        viewModel.setupBinding()
        viewModel.setRoomsFetch()
        
        viewModel.rooms
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.allChatsView.roomsTableView.reloadData()
            }.store(in: &subscriptions)
    }
}

// MARK: - UITableview

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == allChatsView.roomsTableView {
            viewModel.presentCurrentChatScreen(for: indexPath, scrollToMessage: false)
        } else if tableView == allChatsView.searchedMessagesTableView {
            viewModel.presentCurrentChatScreen(for: indexPath, scrollToMessage: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true) // TODO: - check, maybe use tableview keyboard handling method
    }
}

extension AllChatsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView == allChatsView.searchedMessagesTableView
        ? viewModel.getNumberOfSectionForMessages()
        : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == allChatsView.searchedMessagesTableView
        ? viewModel.getNumberOfRowsForMessages(section: section)
        : viewModel.getNumberOfRowsForRooms()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView == allChatsView.searchedMessagesTableView
        ? viewModel.titleForSectionForMessages(section: section)
        : nil
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == allChatsView.searchedMessagesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsSearchedMessageCell.reuseIdentifier, for: indexPath) as? AllChatsSearchedMessageCell

            let data = viewModel.dataForCellForMessages(at: indexPath)
            cell?.configureCell(senderName: data.0, time: data.1, text: data.2)
            return cell ?? EmptyTableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AllChatsTableViewCell.reuseIdentifier, for: indexPath) as? AllChatsTableViewCell
            guard let data = viewModel.dataForCellForRooms(at: indexPath) else { return EmptyTableViewCell() }
            cell?.configureCell(avatarUrl: data.avatarUrl, name: data.name,
                                description: data.description, time: data.time,
                                badgeNumber: data.badgeNumber, muted: data.muted, pinned: data.pinned)
            return cell ?? EmptyTableViewCell()
        }
    }
}

// MARK: - SearchBarDelegate

extension AllChatsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsScope(true, animated: false)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let input = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.search.send(input)
        guard allChatsView.searchBar.selectedScopeButtonIndex == 1 else { return }
        fetchMessages(input: input)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.selectedScopeButtonIndex == 0 {
            searchBar.setShowsScope(false, animated: false)
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        showSelectedTableView(selectedIndex: selectedScope)
        searchBar.setShowsScope(true, animated: false)
        guard let inputText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if allChatsView.searchBar.selectedScopeButtonIndex == 0 && inputText.isEmpty {
            searchBar.setShowsScope(false, animated: false)
        }
        if allChatsView.searchBar.selectedScopeButtonIndex == 1 {
            fetchMessages(input: inputText)
        }
    }
    
    func showSelectedTableView(selectedIndex: Int) {
        allChatsView.roomsTableView.isHidden = selectedIndex == 1
        allChatsView.searchedMessagesTableView.isHidden = selectedIndex == 0
    }
    
    func fetchMessages(input: String) {
        viewModel.setMessagesFetch(searchTerm: input)
        allChatsView.searchedMessagesTableView.reloadData()
    }
}

// MARK: - UITableview swipe animations, ignore for now

extension AllChatsViewController {
    
    private func printSwipe() {
        print("Swipe.")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView == allChatsView.roomsTableView else { return nil }
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
        guard tableView == allChatsView.roomsTableView else { return nil }
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
