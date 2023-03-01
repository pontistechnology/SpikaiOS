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
        
        configureFirebase()
        configureNotifications(app: application)
        customization()
//        test()
        return true
    }
    
    func configureFirebase() {
        FirebaseApp.configure()
        
    }
    
    func test() {
            print("_____")
            Constants.Strings.allCases.enumerated().forEach { index, element in
                print("C ", index, String.getStringFor(element))
                print(String.getStringFor(element) == element.rawValue)
            }
            print("_____")
    }
    
    
    func customization() {
        if let token = UserDefaults(suiteName: Constants.Networking.appGroupName)?.string(forKey: Constants.Database.accessToken) as? String {
            print("TOKEN: ", token)
        }
        
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
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let messageData = userInfo["message"] as? String,
              let jsonData = messageData.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: jsonData) else {
            completionHandler()
            return
        }
        
        let scene = UIApplication.shared.connectedScenes.first
        guard let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) else {
            completionHandler()
            return
        }
        
        DispatchQueue.main.async {
//            let config = HomeViewController.HomeViewControllerStartConfig(startingTab: 0, startWithMessage: message)
            sd.appCoordinator?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: message.roomId))
            completionHandler()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else { return }
            print("New Push fcmToken: ", token)
            let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
            userDefaults.set(token, forKey: Constants.Database.pushToken)
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

