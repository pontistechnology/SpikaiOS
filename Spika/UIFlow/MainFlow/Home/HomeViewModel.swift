//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Combine
import CoreData

class HomeViewModel: BaseViewModel {
    
    var frc: NSFetchedResultsController<RoomEntity>?
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        self.setupUnreadMessagesFrc()
    }
    
    func setupUnreadMessagesFrc() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unreadCount > 0 AND roomDeleted == false")
//        fetchRequest.propertiesToFetch TODO: - add this for optimisation
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp),
                                                         ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func presentChat(roomId: Int64) {
        self.repository.getRoomWithId(forRoomId: roomId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] room in
                self?.getAppCoordinator()?.presentCurrentChatScreen(room: room)
            }.store(in: &self.subscriptions)
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
