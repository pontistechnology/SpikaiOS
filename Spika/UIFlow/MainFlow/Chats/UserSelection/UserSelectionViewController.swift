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
    
    private let viewModel: UserSelectionViewModel
    
    private let userSelectionView = UserSelectionView(frame: CGRectZero)
    
    init(viewModel: UserSelectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        styleSubviews()
        positionSubviews()
        setupBindings()
    }
    
    private func addSubviews() {
        view.addSubview(userSelectionView)
    }
    
    private func styleSubviews() {
        view.backgroundColor = .secondaryColor
    }
    
    private func positionSubviews() {
        userSelectionView.fillSuperview()
    }
    
    private func setupBindings() {
        userSelectionView.searchBar.delegate = self
        userSelectionView.contactsTableView.delegate = self
        userSelectionView.contactsTableView.dataSource = self
        
        userSelectionView
            .doneLabel
            .tap()
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: {  [weak self] in
                    self?.onNext()
                })
            }.store(in: &subscriptions)
        
        userSelectionView.cancelLabel.tap().sink { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        viewModel.reloadUsers
            .sink { [weak self] _ in
                self?.userSelectionView.contactsTableView.reloadData()
                
            }.store(in: &subscriptions)
        
        viewModel.numberOfSelectedUsers
            .sink { [weak self]  number in
                self?.userSelectionView.numberSelectedUsersLabel.text = "\(number) " + .getStringFor(.selected)
            }.store(in: &subscriptions)
    }
    
    private func onNext() {
        viewModel.onDone()
    }
    
}

extension UserSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableViewHeader(text: viewModel.frc?.sections?[section].name ?? "-",
                                     textSize: 18,
                                     textColor: .textPrimary,
                                     fontName: .MontserratSemiBold,
                                     alignment: .left,
                                     labelMargins: UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 14))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectUser(at: indexPath)
        userSelectionView.contactsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension UserSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.frc?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = viewModel.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell,
              let userEntity = viewModel.frc?.object(at: indexPath) else {
            return EmptyTableViewCell()
        }
        let user = User(entity: userEntity)
        
        cell.selectionStyle = .none
        // User Preselected - selection disabled
        
        cell.isUserInteractionEnabled = !viewModel.userSelectionDisabled(user: user)
        // User was selected
        cell.accessoryType = viewModel.userSelected(user: user) ? .checkmark : .none
        cell.tintColor = .tertiaryColor
        
        cell.configureCell(title: user.getDisplayName(),
                            description: user.telephoneNumber,
                            leftImage: user.avatarFileId?.fullFilePathFromId(),
                            type: .normal)
        return cell
    }
}

// MARK: - Search bar
extension UserSelectionViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        if let value = value {
            viewModel.setFetch(withSearch: value)
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        viewModel.setFetch(withSearch: nil)
        view.endEditing(true)
    }
}
