//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Combine
import CoreData

class HomeViewModel: BaseViewModel {
    
//    let unreadChats: PassthroughSubject<Int,Never>
    
    var frc: NSFetchedResultsController<RoomEntity>?
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.setupUnreadMessagesFrc()
    }
    
//    init(repository: Repository, coordinator: Coordinator, unreadChats: PassthroughSubject<Int,Never>) {
//        self.unreadChats = unreadChats
//        super.init(repository: repository, coordinator: coordinator)
//        self.setupUnreadMessagesFrc()
//    }
    
    func setupUnreadMessagesFrc() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)' OR messages.@count > 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp),
                                                         ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        self.frc?.delegate = self
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func getHomeTabBarItems() -> [TabBarItem] {
        return getAppCoordinator()!.getHomeTabBarItems()
    }
    
    func updatePush() {
        repository.updatePushToken().sink { completion in
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                print("Update Push token error:" , error)
            }
        } receiveValue: { response in
            guard let _ = response.data?.device else {
                print("GUARD UPDATE PUSH RESPONSE")
                return
            }
        }.store(in: &subscriptions)
    }
}

extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let allObjects = controller.sections?.first?.objects as? [RoomEntity]
        let count = allObjects?.filter { $0.numberOfUnreadMessages(myUserId: self.getMyUserId()) != 0 }.count ?? 0
        self.repository.unreadRoomsPublisher.send(count)
    }
}
