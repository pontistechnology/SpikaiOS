//
//  DatabaseService.swift
//  Spika
//
//  Created by Vedran Vugrin on 26.04.2023..
//

import CoreData
import Combine

enum DatabaseError: Error {
    case requestFailed, noSuchRecord, unknown, moreThanOne, savingError
    
    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        case .moreThanOne: return "More than one record."
        case .savingError: return "Saving error."
        }
    }
}

class DatabaseService {
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    /// Background task method
    /// - Parameter task: task closure to be executed on a new context
    func performBackgroundTask(task: @escaping(NSManagedObjectContext) -> Void) {
        self.coreDataStack.persistentContainer.performBackgroundTask { context in
            task(context)
        }
    }
    
    /// Synchronous Fetch - use in methods with immediate result
    /// - Parameter entity: Core data entity
    /// - Returns: Array of fetched object
    /// - Parameter context: takes context to perform fetch on
    func fetchEntityAndWait<T:NSManagedObject>(entity: T.Type, context: NSManagedObjectContext) -> [T]? {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        return self.fetchDataAndWait(fetchRequest: fetchRequest, context: context)
    }
    
    /// Synchronous Fetch - use in methods with immediate result
    /// - Parameter fetchRequest: Core data fetch request
    /// - Returns: Array of fetched object
    /// - Parameter context: takes context to perform fetch on
    func fetchDataAndWait<T:NSManagedObject>(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) -> [T]? {
        var data: [T]?
        self.coreDataStack.mainMOC.performAndWait {
            guard let result = try? self.coreDataStack.mainMOC.fetch(fetchRequest),
                  !result.isEmpty else { return }
            data = result
        }
        return data
    }
    
    /// Asynchronous Fetch - use in methods where fetch might require more time
    /// - Parameters:
    ///   - entity: Core data entity
    ///   - completion: Completion returning fetch results or error object
    func fetchAsyncEntity<T:NSManagedObject>(entity: T.Type, completion: @escaping ([T],Error?) -> Void ) {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        self.fetchAsyncData(fetchRequest: fetchRequest, completion: completion)
    }
    
    /// Asynchronous Fetch - use in methods where fetch might require more time
    /// - Parameters:
    ///   - fetchRequest: Core data fetch request
    ///   - completion: Completion returning fetch results or error object
    func fetchAsyncData<T:NSManagedObject>(fetchRequest: NSFetchRequest<T>, completion: @escaping ([T],Error?) -> Void ) {
        self.coreDataStack.persistentContainer.performBackgroundTask { context in
            do {
                let result:[T] = try context.fetch(fetchRequest)
                completion(result,nil)
            } catch let error {
                completion([],error)
            }
        }
    }
    
    /// Save CoreData contect Synchronously
    func saveContextSync() throws {
        var error: Error?
        self.coreDataStack.persistentContainer.viewContext.performAndWait {
            do {
                try self.coreDataStack.mainMOC.save()
            } catch let err {
                error = err
            }
        }
        if let error {
            throw error
        }
    }
    
    
    /// Save function for Core data
    /// - Parameter context: takes context to perform save on
    func save(withContext context: NSManagedObjectContext) throws {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try context.save()
    }
    
}
