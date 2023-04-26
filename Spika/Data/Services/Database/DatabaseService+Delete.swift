//
//  DatabaseService+Delete.swift
//  Spika
//
//  Created by Vedran Vugrin on 26.04.2023..
//

import CoreData
import Combine

extension DatabaseService {
    
    func deleteRoom(roomId: Int64) -> Future<Bool, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let fr = RoomEntity.fetchRequest()
                fr.predicate = NSPredicate(format: "id == %d", roomId)
                guard let roomEntity = try? context.fetch(fr).first else { return }
                
                context.delete(roomEntity)
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure((DatabaseError.savingError)))
                }
            }
        }
    }
    
}
