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
    
    override init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher?) {
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        setupBindings()
        setupUnreadMessagesFrc()
    }
    
    func setupBindings() {
        actionPublisher?.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .deleteReaction(let recordId):
                deleteReaction(recordId: recordId)
            case .forwardMessages(let messageIds, let userIds, let roomIds):
                forwardMessages(messageIds: messageIds, userIds: userIds, roomIds: roomIds)
            case .openRoomWithUser(let userId):
                checkLocalPrivateRoom(id: userId)
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    func setupUnreadMessagesFrc() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unreadCount > 0 AND roomDeleted == false AND lastMessageTimestamp > 0") // last message timestamp is added because messages are local and unread is server side, so you can have unread messages in local empty room (e.g. after new installation)
        
//        fetchRequest.propertiesToFetch TODO: - add this for optimisation
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp),
                                                         ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func presentChat(roomId: Int64) {
        repository.getRoomWithId(forRoomId: roomId)
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
    
    // TODO: - this code is duplicated
    func checkLocalPrivateRoom(id: Int64) {
        repository.checkLocalPrivateRoom(forUserId: id).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                break
            case .failure(_):
                print("no local room")
                checkOnlineRoom(userId: id)
            }
        } receiveValue: { [weak self] room in
            guard let self else { return }
            getAppCoordinator()?.presentCurrentChatScreen(room: room)
        }.store(in: &subscriptions)
    }
    
    func checkOnlineRoom(userId: Int64)  {
        repository.checkOnlineRoom(forUserId: userId).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        } receiveValue: { [weak self] response in
            guard let self else { return }
            if let room = response.data?.room {
                _ = repository.saveLocalRooms(rooms: [room])
                getAppCoordinator()?.presentCurrentChatScreen(room: room)
            } else {
                print("There is no online room, creating started...")
                createRoom(userId: userId)
            }
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int64) {
        repository.createOnlineRoom(userId: userId).receive(on: DispatchQueue.main).sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                showError(error.localizedDescription)
            }
        } receiveValue: { [weak self] response in
            guard let self else { return }
            guard let room = response.data?.room else { return }
            _ = repository.saveLocalRooms(rooms: [room])
            getAppCoordinator()?.presentCurrentChatScreen(room: room)
        }.store(in: &subscriptions)
    }
}

extension HomeViewModel {
    func deleteReaction(recordId: Int64) {
        repository.deleteMessageRecord(recordId: recordId).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let records = response.data?.messageRecords else { return }
            _ = self?.repository.saveMessageRecords(records)
        }.store(in: &subscriptions)
    }
}

extension HomeViewModel {
    func forwardMessages(messageIds: [Int64], userIds: [Int64], roomIds: [Int64]) {
        repository.forwardMessages(messageIds: messageIds, roomIds: roomIds, userIds: userIds).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let self else { return }
            _ = repository.saveLocalRooms(rooms: response.data?.newRooms ?? [])
            _ = repository.saveMessages(response.data?.messages ?? [])
            
            // if forwarded to many, show one sec alert
            guard userIds.count + roomIds.count <= 1 else {
                showOneSecAlert(type: .forward)
                return
            }
            
            // if forwarded to only one, user or room
            if let roomId = response.data?.messages.first?.roomId {
                getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: roomId))
            }
        }.store(in: &subscriptions)
    }
    
    
}
