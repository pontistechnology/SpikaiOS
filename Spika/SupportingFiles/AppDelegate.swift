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
    
    lazy var coreDataStack = CoreDataStack()
    
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
        
        print("start")
        let user1 = User(id: 10101, displayName: "jozara", avatarUrl: "1", telephoneNumber: "22", telephoneNumberHashed: "33", emailAddress: "mm", createdAt: 145)
//        let rUEntity1 = RoomUserEntity(roomUser: RoomUser(userId: 1234, isAdmin: true, user: user1), insertInto: coreDataStack.mainMOC)
        
        let a = UserEntity(user: user1, context: coreDataStack.mainMOC)
        
        coreDataStack.saveMainContext()
        
        print("stop")
        
        let aa = try? coreDataStack.mainMOC.fetch(UserEntity.fetchRequest())
        let bb = aa!.first as? UserEntity
        print(aa?.count)
        print(bb?.displayName)
        
        

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

