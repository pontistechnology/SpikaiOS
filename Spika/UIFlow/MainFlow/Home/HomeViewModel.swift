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
        self.updateUnreadMessages()
    }
    
    func setupUnreadMessagesFrc() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messages.@count > 0")
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
    
    func presentChat(message: Message) {
        repository.getNotificationInfoForMessage(message)
            .receive(on: DispatchQueue.main)
            .sink { c in
            } receiveValue: { [weak self] messageInfo in
                self?.getAppCoordinator()?.presentCurrentChatScreen(room: messageInfo.room)
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

extension HomeViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateUnreadMessages()
    }
    
    func updateUnreadMessages() {
        let allObjects = self.frc?.sections?.first?.objects as? [RoomEntity]
        let count = allObjects?.filter { $0.numberOfUnreadMessages(myUserId: self.getMyUserId()) != 0 }.count ?? 0
        self.repository.unreadRoomsPublisher.send(count)
    }
}
