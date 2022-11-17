//
//  UserSelectionViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import CoreData
import Combine

class UserSelectionViewModel: BaseViewModel {
    
    let preselectedUsers = CurrentValueSubject<[User],Never>([])
    
    private var selectedUsers = CurrentValueSubject<[User],Never>([])
    
    let reloadUsers = PassthroughSubject<Void,Never>()
    
    let numberOfSelectedUsers = CurrentValueSubject<Int,Never>(0)
    
    private let usersSelectedPublisher: PassthroughSubject<[User],Never>
            
    var frc: NSFetchedResultsController<UserEntity>?
    
    init(repository: Repository, coordinator: Coordinator, preselectedUsers: [User], usersSelectedPublisher: PassthroughSubject<[User],Never>) {
        self.preselectedUsers.send(preselectedUsers)
        
        self.usersSelectedPublisher = usersSelectedPublisher
        
        super.init(repository: repository, coordinator: coordinator)
        
        self.setFetch(withSearch: nil)
        self.setupBinding()
    }
    
    func setupBinding() {
        self.preselectedUsers.combineLatest(self.selectedUsers)
            .map { $0.0.count + $0.1.count }
            .subscribe(self.numberOfSelectedUsers)
            .store(in: &self.subscriptions)
    }
    
    func setFetch(withSearch search: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
                NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
            if let search = search, !search.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "contactsName CONTAINS[c] '\(search)' OR telephoneNumber CONTAINS[c] '\(search)'")
            }
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: "sectionName", cacheName: nil)
            self.frc?.delegate = self
            do {
                try self.frc?.performFetch()
                self.updateAllContacts()
            } catch {
                fatalError("Failed to fetch entities: \(error)") // TODO: handle error
            }
        }
    }
    
    private func updateAllContacts() {
        self.reloadUsers.send(Void())
    }
    
    func userSelectionDisabled(user: User) -> Bool {
        return self.preselectedUsers.value.contains(where: { preselectedUser in
            preselectedUser.id == user.id
        })
    }
    
    func userSelected(user: User) -> Bool {
        return self.selectedUsers.value.contains(where: { preselectedUser in
            preselectedUser.id == user.id
        })
        
    }
    
    func selectUser(at indexPath: IndexPath) {
        guard let userEntity = self.frc?.object(at: indexPath) else {
            return
        }
        
        if let index = self.selectedUsers.value.firstIndex(where: { user in
            user.id == userEntity.id
        }) {
            self.selectedUsers.value.remove(at: index)
        } else {
            self.selectedUsers.value.append(User(entity: userEntity))
        }
    }
    
    func onDone() {
        self.usersSelectedPublisher.send(self.selectedUsers.value)
    }
}

extension UserSelectionViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateAllContacts()
    }
}

