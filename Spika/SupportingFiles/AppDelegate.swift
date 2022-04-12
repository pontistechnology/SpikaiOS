//
//  AppDelegate.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import CoreData
import AVFoundation
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AVCaptureDevice.requestAccess(for: .audio) { haveMicAccess in
            print("Access to Microphone: \(haveMicAccess)")
        }
        
        FirebaseApp.configure()
        
        test()
        customization()
        
        return true
    }
    
    func test() {
        // only for debug, remove later
        //        print("type is: ", MessageType(rawValue: "textf"))
        //        UserDefaults.standard.set("QtsRkcMeBVf9nT77", forKey: Constants.UserDefaults.accessToken)
        
        print("Thread check test: ", Thread.current)
//        CoreDataManager.shared.saveContext()
//
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = persistentContainer.viewContext
        print("start")
        privateContext.perform {
            print("Thread check test/cn.test: " , Thread.current)
            let user1 = User(id: 10101, displayName: "mirko", avatarUrl: "1", telephoneNumber: "22", telephoneNumberHashed: "33", emailAddress: "mm", createdAt: 145)
            let rUEntity1 = RoomUserEntity(roomUser: RoomUser(userId: 1234, isAdmin: true, user: user1), insertInto: privateContext)
            do {
                try privateContext.save()
                CoreDataManager.shared.saveContext()
            } catch {
                fatalError("shit")
            }
        }
        
        print("stop")
        
        
        
        
        
        
    }
    
    func customization() {
        guard let font =  UIFont(name: CustomFontName.MontserratSemiBold.rawValue, size: 14) else { return }
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.primaryColor
            ], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
            ], for: .disabled)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
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
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

