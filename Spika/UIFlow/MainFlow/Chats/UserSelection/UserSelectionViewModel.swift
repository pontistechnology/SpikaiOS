//
//  UserSelectionViewModel.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import CoreData
import Combine

class UserSelectionViewModel: BaseViewModel {
    
    typealias Completion = ([User]) -> Void
    
    let preselectedUsers: [User]?
    
//    let allUsers = CurrentValueSubject<[User],Never>([])
    let reloadUsers = PassthroughSubject<Void,Never>()
    
    let completion: Completion
    
    let behaviour = CurrentValueSubject<UserSelectionViewController.UserSelectionBehaviour, Never>(.createNewChat)
    
    var frc: NSFetchedResultsController<UserEntity>?
    
    init(repository: Repository, coordinator: Coordinator, behavior:UserSelectionViewController.UserSelectionBehaviour, completion: @escaping Completion) {
        if case .selectUsers(let preselectedUsers) = behavior {
            self.preselectedUsers = preselectedUsers
        } else {
            self.preselectedUsers = nil
        }
        self.behaviour.send(behavior)
        self.completion = completion
        super.init(repository: repository, coordinator: coordinator)
        
        self.setFetch()
    }
    
    func setFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
                NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
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
    
    func updateAllContacts() {
        self.reloadUsers.send(Void())
//        self.frc?.sections
//        let allObjects = self.frc?.sections?.first?.objects as? [UserEntity]
//        let users = allObjects?.map { User(entity: $0) }
////        let count = allObjects?.filter { $0.numberOfUnreadMessages(myUserId: self.getMyUserId()) != 0 }.count ?? 0
//        self.allUsers.send(users ?? [])
    }
    
    func userAlreadySelected(user: User) -> Bool {
        return self.preselectedUsers?.contains(where: { preselectedUser in
            preselectedUser.id == user.id
        }) ?? false
    }
    
}

extension UserSelectionViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateAllContacts()
    }
}

