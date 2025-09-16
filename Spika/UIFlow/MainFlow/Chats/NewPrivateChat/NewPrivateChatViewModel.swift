//
//  NewPrivateChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.09.2024..
//

import Foundation

class NewPrivateChatViewModel: BaseViewModel, ObservableObject {
    @Published var searchTerm = ""
    
    let usersSortDescriptor = [
        NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
    
    var usersPredicate: NSPredicate? {
        searchTerm.isEmpty
        ? NSPredicate(value: true)
        : NSPredicate(format: "(contactsName CONTAINS[c] '\(searchTerm)' OR telephoneNumber CONTAINS[c] '\(searchTerm)')")
    }
    
    init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher) {
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        setupBindings()
    }
    
    func setupBindings() {
        
    }
}

