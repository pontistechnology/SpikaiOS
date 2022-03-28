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
                print("---TestEntity: ", test.testAttribute ?? "warning removed")
            }
            
            print("\nUsers entities (count: \(users.count)): \n")
            for user in users {
                print("User id \(user.id), created \(user.createdAt), display name \(user.displayName ?? "warning"), avatar url \(user.avatarUrl ?? "wrng"), phonenumber \(user.telephoneNumber ?? "s"), email \(user.emailAddress ?? "s"), given NAme \(user.givenName ?? "a"), family name \(user.familyName ?? "s") ")
            }
            
            print("\nMessages entities (count: \(messages.count)): \n")
            for message in messages {
                print("---MessageEntity: ", message.bodyText ?? "warning", message.roomId, "createdAt: ", message.createdAt)
            }
        }
        catch {
            print("Error occured: ", error.localizedDescription)
        }
    }
    
    func testMESAGESAVINGTOCOREDATA(message: Message){
        let _ = MessageEntity(message: message)
        saveContext()
    }
    
    func FETCHALLMESSAGESFROMDB() -> [MessageEntity] {
        return (try? managedContext.fetch(MessageEntity.fetchRequest())) ?? []
    }
}
