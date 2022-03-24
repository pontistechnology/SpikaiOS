//
//  CoreDataManager.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.03.2022..
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    var managedContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("AppDelegate missing.") }
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveContext() {
        if managedContext.hasChanges{
            do{
                try managedContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func getAllEntities() {
        // this is only for debugging, call po CoreDataManager.shared.getAllEntities from any breakpoint
        
        do {
            let tests = try managedContext.fetch(TestEntity.fetchRequest())
            let users = try managedContext.fetch(UserEntity.fetchRequest())
            let messages = try managedContext.fetch(MessageEntity.fetchRequest())
            
            print("~~~~~~~~~All entities~~~~~~~~~~~~~~ \n")
            print("\nTest entities (count: \(tests.count)): \n")
            for test in tests {
                print("---TestEntity: ", test.testAttribute)
            }
            
            print("\nUsers entities (count: \(users.count)): \n")
            for user in users {
                print("User id \(user.id), created \(user.createdAt), display name \(user.displayName), avatar url \(user.avatarUrl), phonenumber \(user.telephoneNumber), email \(user.emailAddress), given NAme \(user.givenName), family name \(user.familyName) ")
            }
            
            print("\nMessages entities (count: \(messages.count)): \n")
            for message in messages {
                print("---MessageEntity: ", message)
            }
        }
        catch {
            print("Error occured: ", error.localizedDescription)
        }
    }
}
