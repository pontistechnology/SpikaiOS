//
//  CoreDataStack.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.04.2022..
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    static let moduleName = Constants.Database.databaseName
    
    func saveMainContext() {
        guard mainMOC.hasChanges || saveMOC.hasChanges else { return }
        
        mainMOC.performAndWait {
            do {
                try mainMOC.save()
            } catch{
                fatalError("saving main context error")
            }
        }
        
        saveMOC.perform {
            do {
                try self.saveMOC.save()
            } catch {
                fatalError("saveMoc error")
            }
        }
        
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.Database.databaseName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var saveMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return moc
    }()
    
    lazy var mainMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = saveMOC
        return moc
    }()
    
}
