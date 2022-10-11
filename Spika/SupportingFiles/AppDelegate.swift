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
import FirebaseMessaging

 @main
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        configureNotifications(app: application)
        customization()
        test()
        return true
    }
    
    func customization() {
        print("TOKEN: ", UserDefaults(suiteName: Constants.Strings.appGroupName)?.string(forKey: Constants.UserDefaults.accessToken))
        
        guard let font =  UIFont(name: CustomFontName.MontserratSemiBold.rawValue, size: 14) else { return }
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.primaryColor
            ], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
            ], for: .disabled)
    }
}


// MARK: Push notifications

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let m = userInfo["message"] as! String
        let jsonData = m.data(using: .utf8)
        let a = try! JSONDecoder().decode(Message.self, from: jsonData as! Data)
        print("a je :" , a)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else { return }
            print("New Push fcmToken: ", token)
            let userDefaults = UserDefaults(suiteName: Constants.Strings.appGroupName)!
            userDefaults.set(token, forKey: Constants.UserDefaults.pushToken)
        }
    }
    
    func configureNotifications(app: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            guard success else { return }
            print("APNs registred.")
        }
        app.registerForRemoteNotifications()
    }
}

// MARK: CoreData, testing, TODO: delete later

extension AppDelegate {
    
    func test() {
//        let userDefaults = UserDefaults(suiteName: Constants.Strings.appGroupName)!
//        userDefaults.set("fich0x3WTUwjlGF5", forKey: Constants.UserDefaults.accessToken)
    }
    
    func allroomsprinter() {
        let coreDataStack = CoreDataStack()

        let fr = RoomEntity.fetchRequest()
        fr.predicate = NSPredicate(format: "type == 'private' AND ANY users.userId == 12")
        let aa = try! coreDataStack.mainMOC.fetch(fr)
        print(aa.count)
        for a in aa {
            print("Count of users: ", a.users!.count)
            for user in a.users! {
                print("Begi user: ", (user as! RoomUserEntity).user!.displayName!)
            }
        }
    }
}

