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
    
    override init() {
        print("CoredataStack init")
    }
    
    deinit {
        print("CoredataStack deinit")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.Database.databaseName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var saveMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()
    
    lazy var mainMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = saveMOC
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()
    
    lazy var backgroundMOC: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = mainMOC
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()
    
    
}

// MARK: - Functions

extension CoreDataStack {
    
    func saveBackgroundMOC() {
        
        backgroundMOC.perform {
            guard self.backgroundMOC.hasChanges else { return }
            
            do {
                try self.backgroundMOC.save()
                self.saveToDisk()
            } catch {
                fatalError("Background MOC saving fail.")
            }
        }
    }

    private func saveToDisk() {
        let s = CFAbsoluteTimeGetCurrent()
        mainMOC.performAndWait {
            do {
                try mainMOC.save()
            } catch{
                fatalError("saving main context error")
            }
        }
        
        let e = CFAbsoluteTimeGetCurrent()
        
        print("Duration of main saving", e-s)
        
        saveMOC.perform {
            do {
                try self.saveMOC.save()
            } catch {
                fatalError("saveMoc error")
            }
        }
    }
}
