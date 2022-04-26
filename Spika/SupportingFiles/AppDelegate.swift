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
        registerForPushNotifications()
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
            print("Count of users: ", a.users!.count)
            for user in a.users! {
                print("Begi user: ", (user as! RoomUserEntity).user!.displayName!)
            }
        }
    }
    
    func test() {
        // only for debug, remove later
        // print("type is: ", MessageType(rawValue: "textf"))
         UserDefaults.standard.set("STx4njvXxPVOgxR7", forKey: Constants.UserDefaults.accessToken)
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
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Push Token: \(token)")
        UserDefaults.standard.set(token, forKey: Constants.UserDefaults.pushToken)
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("PUSH: ", userInfo)
        if let aps = userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any] {
            let title = alert["title"] as? String ?? ""
            let body = alert["body"] as? String ?? ""
            
            
        }
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

