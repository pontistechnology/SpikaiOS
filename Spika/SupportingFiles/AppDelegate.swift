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
//        allroomsprinter()
//        test()
        customization()
        
        return true
    }
    
    let coreDataStack = CoreDataStack()
    
    func allroomsprinter() {
        let fr = RoomEntity.fetchRequest()
        fr.predicate = NSPredicate(format: "type == 'private' AND ANY users.userId == 12")
        let aa = try! coreDataStack.mainMOC.fetch(fr)
        print(aa.count)
        for a in aa {
//            print("Begi room: ", a.type)
            print("Count of users: ", a.users!.count)
            for user in a.users! {
                print("Begi user: ", (user as! RoomUserEntity).user!.displayName!)
            }
        }
    }
    
    func test() {
        // only for debug, remove later
        //        print("type is: ", MessageType(rawValue: "textf"))
//                UserDefaults.standard.set("QtsRkcMeBVf9nT77", forKey: Constants.UserDefaults.accessToken)
        
        print("Thread check test: ", Thread.current)


        let roomaga = Room(id: 15, type: "private", name: "CloverAll", avatarUrl: "nema", createdAt: 43,
                           users: [
                            RoomUser(userId: 12,
                                            isAdmin: true,
                                            user: User(id: 12,
                                                       displayName: "nikola",
                                                       avatarUrl: "n")
                                    ),
                           RoomUser(userId: 13,
                                    isAdmin: false,
                                    user: User(id: 13,
                                               displayName: "mia",
                                               avatarUrl: "f")
                                   )
                           ])
        
        coreDataStack.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            _ = RoomEntity(room: roomaga, context: context)
            try! context.save()
        }
        
        
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
}

