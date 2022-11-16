//
//  UserSelectionViewController.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import Foundation
import UIKit
import CoreData

class UserSelectionViewController: BaseViewController {
 
    enum UserSelectionBehaviour {
        case selectUsers(preselectedUsers: [User])
        case createNewChat
        case createNewGroup
    }
    
    let viewModel: UserSelectionViewModel
    
    let userSelectionView = UserSelectionView(frame: CGRectZero)
    
    init(viewModel: UserSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.positionSubviews()
        self.setupBindings()
    }
    
    func addSubviews() {
        self.view.addSubview(self.userSelectionView)
    }
    
    func positionSubviews() {
        self.userSelectionView.fillSuperview()
    }
    
    func setupBindings() {
//        userSelectionView.searchBar.delegate = self
        userSelectionView.contactsTableView.delegate = self
        userSelectionView.contactsTableView.dataSource = self
//        userSelectionView.groupUsersCollectionView.delegate = self
//        userSelectionView.groupUsersCollectionView.dataSource = self
        
        userSelectionView.cancelLabel.tap().sink { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &subscriptions)
        
//        userSelectionView.chatOptionLabel.tap().sink { [weak self] _ in
//            guard let self = self else { return }
//            self.userSelectionView.setGroupUserVisible(self.userSelectionView.groupUsersCollectionView.isHidden ? true : false)
//        }.store(in: &subscriptions)
        
//        userSelectionView.nextLabel.tap().sink { [weak self] _ in
//            guard let self = self else { return }
////            self.viewModel.presentNewGroupScreen()
//        }.store(in: &subscriptions)
        
        viewModel.reloadUsers
            .sink { _ in
                self.userSelectionView.contactsTableView.reloadData()
            }.store(in: &subscriptions)
//        viewModel.contactsSubject.receive(on: DispatchQueue.main).sink { [weak self] _ in
//            guard let self = self else { return }
//            self.userSelectionView.contactsTableView.reloadData()
//        }.store(in: &subscriptions)
//
//        viewModel.selectedUsersSubject.receive(on: DispatchQueue.main).sink { [weak self] selectedContacts in
//            guard let self = self else { return }
//            self.userSelectionView.numberSelectedUsersLabel.text = "\(selectedContacts.count) / 100 selected"
//            self.userSelectionView.groupUsersCollectionView.reloadData()
//        }.store(in: &subscriptions)
    }
    
}

extension UserSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableViewHeader(text: self.viewModel.frc?.sections?[section].name ?? "-",
                                     textSize: 18,
                                     textColor: .textPrimary,
                                     fontName: .MontserratSemiBold,
                                     alignment: .left,
                                     labelMargins: UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 14))
    }
}

extension UserSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.frc?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.viewModel.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        guard let userEntity = self.viewModel.frc?.object(at: indexPath) else {
            return UITableViewCell()
        }
        let user = User(entity: userEntity)
        
        cell?.backgroundColor = self.viewModel.userAlreadySelected(user: user) ? .lightGray : .white
        cell?.isUserInteractionEnabled = !self.viewModel.userAlreadySelected(user: user)
        
        cell?.configureCell(user)
        return cell ?? UITableViewCell()
    }
}
